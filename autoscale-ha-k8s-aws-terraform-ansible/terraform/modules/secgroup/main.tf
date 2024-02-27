resource "aws_security_group" "matt-kube-mutual-sg" {
  name = "kube-mutual-sec-group-for-${var.PROJECT_IDENTIFIER}"
}

resource "aws_security_group" "matt-kube-worker-sg" {
  name = "kube-worker-sec-group-for-${var.PROJECT_IDENTIFIER}"

  ingress {
    protocol = "-1"
    from_port = 0
    to_port = 0
    security_groups = [aws_security_group.matt-kube-mutual-sg.id]
  }
  
  ingress {
    protocol = "tcp"
    from_port = 10250
    to_port = 10250
    security_groups = [aws_security_group.matt-kube-mutual-sg.id]
  }

  # ingress {
    #   protocol = "tcp"
    #   from_port = 30000
    #   to_port = 32767
    #   cidr_blocks = ["0.0.0.0/0"]
    # }

    # ingress {
    #   protocol = "tcp"
    #   from_port = 22
    #   to_port = 22
    #   cidr_blocks = ["0.0.0.0/0"]
    # }

    # ingress {
    #   protocol = "tcp"
    #   from_port = 6783
    #   to_port = 6783
    #   security_groups = [aws_security_group.matt-kube-mutual-sg.id]
    # }
    # ingress {
    #   protocol = "udp"
    #   from_port = 6783
    #   to_port = 6784
    #   security_groups = [aws_security_group.matt-kube-mutual-sg.id]
    # }
  
  ingress {
    protocol = "tcp"
    from_port = 443
    to_port = 443
    security_groups = [aws_security_group.matt-kube-mutual-sg.id]
  }
  ingress {
    protocol = "tcp"
    from_port = 179
    to_port = 179
    security_groups = [aws_security_group.matt-kube-mutual-sg.id]
  }
  # ingress {
  #   protocol = "udp"
  #   from_port = 8472
  #   to_port = 8472
  #   security_groups = [aws_security_group.matt-kube-mutual-sg.id]
  # }
  
  egress{
    protocol = "-1"
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "kube-worker-secgroup"
    "kubernetes.io/cluster/${var.PROJECT_IDENTIFIER}-worker" = "owned"
    "k8s.io/cluster-autoscaler-workers/enabled" = "true"
    "kubernetes.io/cluster/${var.PROJECT_IDENTIFIER}" = "owned"
  }
}

resource "aws_security_group" "matt-kube-master-sg" {
  name = "kube-master-sec-group-for-${var.PROJECT_IDENTIFIER}"

  ingress {
    protocol = "tcp"
    from_port = 22
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # ingress {
  #   protocol = "tcp"
  #   from_port = 80
  #   to_port = 80
  #   cidr_blocks = ["0.0.0.0/0"]
  # }
  
  ingress {
    protocol = "tcp"
    from_port = 6443
    to_port = 6443
    cidr_blocks = ["0.0.0.0/0"]
    #security_groups = [aws_security_group.matt-kube-mutual-sg.id]
  }

  # ingress {
  #   protocol = "tcp"
  #   from_port = 30000
  #   to_port = 32767
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  # ingress {
  #   protocol = "tcp"
  #   from_port = 443
  #   to_port = 443
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  # ingress {
  #   protocol = "tcp"
  #   from_port = 6783
  #   to_port = 6783
  #   security_groups = [aws_security_group.matt-kube-mutual-sg.id]
  # }
  # ingress {
  #   protocol = "udp"
  #   from_port = 6783
  #   to_port = 6784
  #   security_groups = [aws_security_group.matt-kube-mutual-sg.id]
  # }

  ingress {
    protocol = "tcp"
    from_port = 10250
    to_port = 10252
    security_groups = [aws_security_group.matt-kube-mutual-sg.id]
  }

  ingress {
    protocol = "tcp"
    from_port = 179
    to_port = 179
    security_groups = [aws_security_group.matt-kube-mutual-sg.id]
  }
  # ingress {
  #   protocol = "udp"
  #   from_port = 8472
  #   to_port = 8472
  #   security_groups = [aws_security_group.matt-kube-mutual-sg.id]
  # }

  ingress {
    protocol = "tcp"
    from_port = 2379
    to_port = 2380
    security_groups = [aws_security_group.matt-kube-mutual-sg.id]
  }
  
  ingress {
    protocol = "-1"
    from_port = 0
    to_port = 0
    security_groups = [aws_security_group.matt-kube-mutual-sg.id]
  }

  egress {
    protocol = "-1"
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "kube-master-secgroup"
    "kubernetes.io/cluster/${var.PROJECT_IDENTIFIER}" = "owned"
  }
}

output mutual_sec_group_id {
  value       = aws_security_group.matt-kube-mutual-sg.id
}

output controlplane_sec_group_id {
  value       = aws_security_group.matt-kube-master-sg.id
}

output workers_sec_group_id {
  value       = aws_security_group.matt-kube-worker-sg.id
}







# resource "aws_security_group" "matt-kube-alb-sg" {
  #   name = "kube-alb-sec-group-for-matt"

  #   ingress {
  #     protocol = "tcp"
  #     from_port = 6443
  #     to_port = 6443
  #     cidr_blocks = ["0.0.0.0/0"]
  #     #security_groups = [aws_security_group.matt-kube-mutual-sg.id]
  #   }

  #   egress {
  #     protocol = "-1"
  #     from_port = 0
  #     to_port = 0
  #     cidr_blocks = ["0.0.0.0/0"]
  #   }

  #   tags = {
  #     Name = "kube-alb-secgroup"
  #     # "kubernetes.io/cluster/mattsCluster" = "owned"
  #   }
  # }

  # output alb_sec_group_id {
  #   value       = aws_security_group.matt-kube-alb-sg.id
  # }
