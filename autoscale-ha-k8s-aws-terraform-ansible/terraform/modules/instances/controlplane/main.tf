module "iam" {
  source = "../../IAM/controlplane"
}

module "secgroup" {
  source = "../../secgroup"
}

resource "aws_instance" "kube-master" {
  # ami = "ami-05f7491af5eef733a"
  ami = "ami-09e67e426f25ce0d7"
  instance_type = "t2.medium"
  iam_instance_profile = module.iam.master_profile_name
  vpc_security_group_ids = [module.secgroup.controlplane_sec_group_id, module.secgroup.mutual_sec_group_id]
  key_name = "gitlab-ec2-access"
  # key_name = "mattseukey"
  subnet_id = "subnet-11a23d30"
  availability_zone = "us-east-1b" 
  # subnet_id = "subnet-0b3d4b8909fdba8c5"
  # availability_zone = "eu-central-1a" 
  tags = {
      Name = "kube-master"
      "kubernetes.io/cluster/mattsCluster" = "owned"
      Project = "autoscale-ha-k8s"
      Plane = "controlplane"
      Role = "master"
      Id = "1"
  }
}

# resource "aws_instance" "kube-master-proxy-1" {
  #     ami = "ami-09e67e426f25ce0d7"
  #     # ami = "ami-05f7491af5eef733a"
  #     instance_type = "t2.medium"
  #     iam_instance_profile = module.iam.master_profile_name
  #     vpc_security_group_ids = [module.secgroup.controlplane_sec_group_id, module.secgroup.mutual_sec_group_id]
  #     key_name = "gitlab-ec2-access"
  #     # key_name = "mattseukey"
  #     subnet_id = "subnet-11a23d30"
  #     availability_zone = "us-east-1b" 
  #     # subnet_id = "subnet-0b3d4b8909fdba8c5"
  #     # availability_zone = "eu-central-1a" 
  #     tags = {
  #         Name = "kube-master-proxy-1"
  #         "kubernetes.io/cluster/mattsCluster" = "owned"
  #         Project = "autoscale-ha-k8s"
  #         Plane = "controlplane"
  #         Role = "master-proxy"
  #         Id = "1"
  #     }
  # }

  # resource "aws_instance" "kube-master-proxy-2" {
  #     ami = "ami-09e67e426f25ce0d7"
  #     # ami = "ami-05f7491af5eef733a"
  #     instance_type = "t2.medium"
  #     iam_instance_profile = module.iam.master_profile_name
  #     vpc_security_group_ids = [module.secgroup.controlplane_sec_group_id, module.secgroup.mutual_sec_group_id]
  #     key_name = "gitlab-ec2-access"
  #     # key_name = "mattseukey"
  #     subnet_id = "subnet-11a23d30"
  #     availability_zone = "us-east-1b" 
  #     # subnet_id = "subnet-0b3d4b8909fdba8c5"
  #     # availability_zone = "eu-central-1a" 
  #     tags = {
  #         Name = "kube-master-proxy-2"
  #         "kubernetes.io/cluster/mattsCluster" = "owned"
  #         Project = "autoscale-ha-k8s"
  #         Plane = "controlplane"
  #         Role = "master-proxy"
  #         Id = "2"
  #     }
  # }

resource "aws_launch_template" "asg-lt" {
  name = "autoscale-ha-k8s-lt"
  image_id = "ami-09e67e426f25ce0d7"
  # image_id = "ami-05f7491af5eef733a"
  instance_type = "t2.medium"
  key_name = "gitlab-ec2-access"
  # key_name = "mattseukey"
  vpc_security_group_ids = [module.secgroup.controlplane_sec_group_id, module.secgroup.mutual_sec_group_id]
  user_data = filebase64("./user-data.sh")
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "kube-master-proxy-LT"
      "kubernetes.io/cluster/mattsCluster" = "owned"
      Project = "autoscale-ha-k8s"
      Plane = "controlplane"
      Role = "master-proxy"
    }
  }
}

output kube-master-ip {
  value       = aws_instance.kube-master.public_ip
  sensitive   = false
  description = "public ip of the kube-master"
}

# output kube-master-proxy-1-ip {
  #   value       = aws_instance.kube-master-proxy-1.public_ip
  #   sensitive   = false
  #   description = "public ip of the kube-master-proxy-1"
  # }

  # output kube-master-proxy-2-ip {
  #   value       = aws_instance.kube-master-proxy-2.public_ip
  #   sensitive   = false
  #   description = "public ip of the kube-master-proxy-2"
  # }

output kube-master-id {
  value       = aws_instance.kube-master.id
  sensitive   = false
  description = "public ip of the kube-master"
}

# output kube-master-proxy-1-id {
  #   value       = aws_instance.kube-master-proxy-1.id
  #   sensitive   = false
  #   description = "public ip of the kube-master-proxy-1"
  # }

  # output kube-master-proxy-2-id {
  #   value       = aws_instance.kube-master-proxy-2.id
  #   sensitive   = false
  #   description = "public ip of the kube-master-proxy-2"
  # }

output asg-lt-id {
  value       = aws_launch_template.asg-lt.id
  sensitive   = false
}

output asg-lt-version {
  value       = aws_launch_template.asg-lt.latest_version
  sensitive   = false
}