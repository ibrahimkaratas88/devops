//This Terraform Template creates 4 Ansible Machines on EC2 Instances
//Ansible Machines will run on Amazon Linux 2 and Ubuntu 20.04 with custom security group
//allowing SSH (22) and HTTP (80) connections from anywhere.
//User needs to select appropriate key name when launching the instance.

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  profile = "ibrahim"
#  secret_key = ""
#  access_key = ""
}

variable "tags" {
  default = ["control_node", "node_1", "node_2"]
}

resource "aws_instance" "amazon-linux-2" {
  ami = "ami-0a8b4cd432b1c3063"
  instance_type = "t2.micro"
  count = 3
  key_name = "ibrahim"
  security_groups = ["ansible-session-sec-gr"]
  tags = {
    Name = element(var.tags, count.index)
  }
}


resource "aws_instance" "ubuntu" {
  ami = "ami-04505e74c0741db8d"
  instance_type = "t2.micro"
  key_name = "ibrahim"
  security_groups = ["ansible-session-sec-gr"]

tags = {
  Name = "node_3"
}
}

resource "aws_security_group" "tf-sec-gr" {
  name = "ansible-session-sec-gr"
  tags = {
    Name = "ansible-session-sec-gr"
  }

  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    protocol    = -1
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "null_resource" "config" {
  depends_on = [aws_instance.amazon-linux-2[0]]
  connection {
    host = aws_instance.amazon-linux-2[0].public_ip
    type = "ssh"
    user = "ec2-user"
    private_key = file("~/ibrahim.pem")
    }

  provisioner "file" {
  source = "./ansible.cfg"
  destination = "/home/ec2-user/ansible.cfg"
}

  provisioner "file" {
    source = "~/ibrahim.pem"
    destination = "/home/ec2-user/ibrahim.pem"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname Control-Node",
      "sudo yum update -y",
      "sudo amazon-linux-extras install ansible2 -y",
      "echo [webservers] >> inventory.txt",
      "echo node1  ansible_host=${aws_instance.amazon-linux-2[1].private_ip}  ansible_ssh_private_key_file=~/ibrahim.pem ansible_user=ec2-user >> inventory.txt",
      "echo node2 ansible_host=${aws_instance.amazon-linux-2[2].private_ip}  ansible_ssh_private_key_file=~/ibrahim.pem ansible_user=ec2-user >> inventory.txt",
      "echo [ubuntuservers] >> inventory.txt",
      "echo node3 ansible_host=${aws_instance.ubuntu.private_ip}  ansible_ssh_private_key_file=~/ibrahim.pem ansible_user=ubuntu >> inventory.txt",
      "chmod 400 ibrahim.pem"
    ]
  }

}

output "controlnodeip" {
  value = aws_instance.amazon-linux-2[0].public_ip
}
