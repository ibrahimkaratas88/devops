module "iam2" {
  source = "./modules/IAM/workers"
  PROJECT_IDENTIFIER = "${var.PROJECT_IDENTIFIER}"
}

resource "aws_autoscaling_group" "asg_worker_1" {
  name = "autoscale-ha-k8s-worker-asg-1-${var.PROJECT_IDENTIFIER}"
  desired_capacity = var.DESIRED_CAPACITY_WORKER_1
  max_size = var.MAX_SIZE_WORKER_1
  min_size = var.MIN_SIZE_WORKER_1
  default_cooldown = 100
  health_check_grace_period = 300
  health_check_type = "ELB"
  vpc_zone_identifier = [var.SUBNET_1]
  launch_template {
    id = aws_launch_template.launch_template_worker.id
    version = aws_launch_template.launch_template_worker.latest_version
  }
  tag {
      key                 = "kubernetes.io/cluster/${var.PROJECT_IDENTIFIER}-worker-1"
      value               = "owned"
      propagate_at_launch = true
    }
}

resource "aws_autoscaling_group" "asg_worker_2" {
  name = "autoscale-ha-k8s-worker-asg-2-${var.PROJECT_IDENTIFIER}"
  desired_capacity = var.DESIRED_CAPACITY_WORKER_2
  max_size = var.MAX_SIZE_WORKER_2
  min_size = var.MIN_SIZE_WORKER_2
  default_cooldown = 100
  health_check_grace_period = 300
  health_check_type = "ELB"
  vpc_zone_identifier = [var.SUBNET_2]
  launch_template {
    id = aws_launch_template.launch_template_worker.id
    version = aws_launch_template.launch_template_worker.latest_version
  }
  tag {
      key                 = "kubernetes.io/cluster/${var.PROJECT_IDENTIFIER}-worker-2"
      value               = "owned"
      propagate_at_launch = true
    }
}

resource "aws_launch_template" "launch_template_worker" {
  name = "autoscale-ha-k8s-worker-lt-${var.PROJECT_IDENTIFIER}"
  image_id = var.AMI_ID
  
  iam_instance_profile {
    name = module.iam2.worker_profile_name
  } 
  instance_type = var.INSTANCE_TYPE
  key_name = var.KEY_NAME
  depends_on = [aws_instance.kube-master]
  vpc_security_group_ids = [module.secgroup.workers_sec_group_id, module.secgroup.mutual_sec_group_id]
  user_data = filebase64("./user-data-workers.sh")
  
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
      Name = "kube-worker-LT-${var.PROJECT_IDENTIFIER}"
      "kubernetes.io/cluster/${var.PROJECT_IDENTIFIER}" = "owned"
      Project = "autoscale-ha-k8s-${var.PROJECT_IDENTIFIER}"
      Plane = "workersplane-${var.PROJECT_IDENTIFIER}"
      Role = "worker${var.PROJECT_IDENTIFIER}"
    }
  }
}
