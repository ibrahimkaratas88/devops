terraform {
  backend "http" {
  }
}

provider "aws" {
  region = "${var.REGION}"
}

module "iam" {
  source = "./modules/IAM/controlplane"
  PROJECT_IDENTIFIER = "${var.PROJECT_IDENTIFIER}"
}

module "secgroup" {
  source = "./modules/secgroup"
  PROJECT_IDENTIFIER = "${var.PROJECT_IDENTIFIER}"
}

resource "aws_alb" "loadbalancer_controlplane" {
  name = "autoscale-ha-k8s-alb-${var.PROJECT_IDENTIFIER}"
  ip_address_type = "ipv4"
  internal = false
  load_balancer_type = "network"
  subnets = ["${var.SUBNET_1}", "${var.SUBNET_2}"]
}

resource "aws_alb_listener" "alb_listener_controlplane" {
  load_balancer_arn = aws_alb.loadbalancer_controlplane.arn
  port = "${var.LISTENER_PORT}"
  protocol = "TCP"
  default_action {
    type = "forward"
    target_group_arn = aws_alb_target_group.target_group_controlplane.arn
  }
}

resource "aws_alb_target_group" "target_group_controlplane" {
  name = "autoscale-ha-k8s-tg-${var.PROJECT_IDENTIFIER}"
  port = "${var.TARGET_GROUP_PORT}"
  protocol = "TCP"
  vpc_id = var.VPC_ID
  target_type = "instance"
  depends_on = [aws_alb.loadbalancer_controlplane]
  health_check {
    port = 22
    protocol = "TCP"
    healthy_threshold = 3
    unhealthy_threshold = 3
  }
}

resource "aws_instance" "kube-master" {
  ami = var.AMI_ID
  instance_type = var.INSTANCE_TYPE
  depends_on = [aws_alb.loadbalancer_controlplane, aws_alb_listener.alb_listener_controlplane, aws_alb_target_group.target_group_controlplane]
  iam_instance_profile = module.iam.master_profile_name
  vpc_security_group_ids = [module.secgroup.controlplane_sec_group_id, module.secgroup.mutual_sec_group_id]
  key_name = var.KEY_NAME
  availability_zone = var.KUBE_MASTER_AZ
  subnet_id = var.KUBE_MASTER_SUBNET_ID
  root_block_device {
    volume_size   = var.VOLUME_SIZE
    volume_type   = var.VOLUME_TYPE
  }
  tags = {
      Name = "kube-master_${var.PROJECT_IDENTIFIER}"
      "kubernetes.io/cluster/${var.PROJECT_IDENTIFIER}" = "owned"
      Project = "autoscale-ha-k8s-${var.PROJECT_IDENTIFIER}"
      Plane = "controlplane-${var.PROJECT_IDENTIFIER}"
      Role = "master${var.PROJECT_IDENTIFIER}"
      Id = "1"
  }

  provisioner "remote-exec" {
    inline = ["sudo apt update", "sudo apt install python3 -y", "sudo apt-get update", "sudo apt-get install awscli -y", "aws elbv2 register-targets --target-group-arn ${aws_alb_target_group.target_group_controlplane.arn} --targets Id=${self.id},Port=${var.TARGET_GROUP_PORT} --region ${var.REGION}", "echo CheckTheTargetGroup!...", "/bin/bash -c 'until [[ $(aws elbv2 describe-target-health --target-group-arn ${aws_alb_target_group.target_group_controlplane.arn} --query TargetHealthDescriptions[*].Target.Id --region ${var.REGION}) == *${self.id}* ]]; do echo notReady; done; echo ready'"]

    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("gitlabkey.cer")
    }
  }

  provisioner "local-exec" {
   command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ../ansible/dynamic-inventory-aws_ec2.yml -e 'CONTROLPLANE_ENDPOINT=${aws_alb.loadbalancer_controlplane.dns_name} PUBLIC_IP=${self.public_ip} PROJECT_IDENTIFIER=${var.PROJECT_IDENTIFIER} REGION=${var.REGION} ansible_ssh_private_key_file=gitlabkey.cer' ../ansible/playbook-master.yml"
  }
}

resource "aws_lb_target_group_attachment" "kube-master" {
  target_group_arn = aws_alb_target_group.target_group_controlplane.arn
  target_id        = aws_instance.kube-master.id
  port             = var.TARGET_GROUP_PORT
}

resource "aws_autoscaling_group" "asg_controlplane" {
  name = "autoscale-ha-k8s-asg-${var.PROJECT_IDENTIFIER}"
  desired_capacity = var.DESIRED_CAPACITY_CTRLPLANE
  max_size = var.MAX_SIZE_CTRLPLANE
  min_size = var.MIN_SIZE_CTRLPLANE
  default_cooldown = 100
  depends_on = [aws_instance.kube-master]
  health_check_grace_period = 300
  health_check_type = "ELB"
  target_group_arns = [aws_alb_target_group.target_group_controlplane.arn]
  vpc_zone_identifier = [var.SUBNET_1, var.SUBNET_2]
  launch_template {
    id = aws_launch_template.launch_template_controlplane.id
    version = aws_launch_template.launch_template_controlplane.latest_version
  }
  tag {
      key                 = "kubernetes.io/cluster/${var.PROJECT_IDENTIFIER}"
      value               = "owned"
      propagate_at_launch = false
    }
}

resource "aws_launch_template" "launch_template_controlplane" {
  name = "autoscale-ha-k8s-lt-${var.PROJECT_IDENTIFIER}"
  image_id = var.AMI_ID
  iam_instance_profile {
    name = module.iam.master_profile_name
  } 
  instance_type = var.INSTANCE_TYPE
  key_name = var.KEY_NAME

  depends_on = [aws_instance.kube-master]
  vpc_security_group_ids = [module.secgroup.controlplane_sec_group_id, module.secgroup.mutual_sec_group_id]
  user_data = filebase64("./user-data.sh")
  
  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size = var.VOLUME_SIZE
      volume_type = var.VOLUME_TYPE
    }
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "kube-master-proxy-LT-${var.PROJECT_IDENTIFIER}"
      Project = "autoscale-ha-k8s-${var.PROJECT_IDENTIFIER}"
      Plane = "controlplane-${var.PROJECT_IDENTIFIER}"
      Role = "master_proxy${var.PROJECT_IDENTIFIER}"
      "kubernetes.io/cluster/${var.PROJECT_IDENTIFIER}" = "owned"
    }
  }
}
