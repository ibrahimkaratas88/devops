module "iam" {
  source = "./modules/IAM/workers"
}

module "secgroup" {
  source = "./modules/secgroup"
}

resource "aws_instance" "worker-1" {
    ami = "ami-05f7491af5eef733a"
    instance_type = "t2.medium"
        iam_instance_profile = module.iam.worker_profile_name
    vpc_security_group_ids = [module.secgroup.workers_sec_group_id, module.secgroup.mutual_sec_group_id]
    key_name = "ibrahim"
    subnet_id = "subnet-0b3d4b8909fdba8c5"
    availability_zone = "eu-central-1a"
    tags = {
        Name = "worker-1"
        "kubernetes.io/cluster/mattsCluster" = "owned"
        Project = "autoscale-ha-k8s"
        Plane = "workersplane"
        Role = "worker"
        Id = "1"
    }
}

resource "aws_instance" "worker-2" {
    ami = "ami-05f7491af5eef733a"
    instance_type = "t2.medium"
    iam_instance_profile = module.iam.worker_profile_name
    vpc_security_group_ids = [module.secgroup.workers_sec_group_id, module.secgroup.mutual_sec_group_id]
    key_name = "ibrahim"
    subnet_id = "subnet-0b3d4b8909fdba8c5"
    availability_zone = "eu-central-1a"
    tags = {
        Name = "worker-2"
        "kubernetes.io/cluster/mattsCluster" = "owned"
        Project = "autoscale-ha-k8s"
        Plane = "workersplane"
        Role = "worker"
        Id = "2"
    }
}

output worker-1-ip {
  value       = aws_instance.worker-1.public_ip
  sensitive   = false
  description = "public ip of the worker-1"
}

output worker-2-ip {
  value       = aws_instance.worker-2.public_ip
  sensitive   = false
  description = "public ip of the worker-2"
}
