provider "aws" {
  region = "us-east-1"
  //  access_key = ""
  //  secret_key = ""
  //  If you have entered your credentials in AWS CLI before, you do not need to use these arguments.
}

variable "ansible-tags" {
  type    = list(string)
  default = ["node_1", "node_2"]
}

data "aws_ami" "tf-ami" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_instance" "tf-ansible-control-node" {
  ami           = data.aws_ami.tf-ami.id
  instance_type = "t2.micro"
  key_name      = "northvirginia"
  //  Write your pem file name
  security_groups = ["ansible-sec-gr"]
  tags = {
    Name = "Control_Node"
  }
  user_data = file("ansible-installation.sh")
}

resource "aws_instance" "tf-ansible-node" {
  ami           = data.aws_ami.tf-ami.id
  instance_type = "t2.micro"
  key_name      = "northvirginia"
  //  Write your pem file name
  security_groups = ["ansible-sec-gr"]
  count           = 2
  tags = {
    Name = element(var.ansible-tags, count.index)
  }
}

resource "aws_security_group" "tf-ansible-sec-gr" {
  name = "ansible-sec-gr"
  tags = {
    Name = "ansible-sec-group"
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

output "public-ip-of-nodes" {
  value = aws_instance.tf-ansible-node[*].public_ip
}

output "private-ip-of-nodes" {
  value = aws_instance.tf-ansible-node[*].private_ip
}

