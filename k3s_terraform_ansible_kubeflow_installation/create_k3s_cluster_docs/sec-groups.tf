resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default-VPC"
  }
}

#resource "aws_vpc" "default" {
  #cidr_block = "172.31.0.0/16"
  #id = var.vpc_id
#}


resource "aws_security_group" "k3s_server_new" {
  name        = "k3s-server-new"
  #description = "Allow TLS inbound traffic"
  vpc_id      = aws_default_vpc.default.id

  ingress = [ 
    {    
      description      = "for ssh"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"] 
      prefix_list_ids = null
      security_groups = null
      self = null
      #security_group_id = aws_security_group.k3s_server.id      
    },
    {    
      description      = "for http"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"] 
      prefix_list_ids = null
      security_groups = null
      self = null
      #security_group_id = aws_security_group.k3s_server.id      
    },
    {    
      description      = "for http2"
      from_port        = 8080
      to_port          = 8080
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"] 
      prefix_list_ids = null
      security_groups = null
      self = null
      #security_group_id = aws_security_group.k3s_server.id      
    },
    {    
      description      = "for https"
      from_port        = 443
      to_port          = 443
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"] 
      prefix_list_ids = null
      security_groups = null
      self = null
      #security_group_id = aws_security_group.k3s_server.id      
    },
    {    
      description      = "for k8s"
      from_port        = 6443
      to_port          = 6443
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"] 
      prefix_list_ids = null
      security_groups = null
      self = null
      #security_group_id = aws_security_group.k3s_server.id      
    },
    {      
      description      = "all"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"] 
      prefix_list_ids = null
      security_groups = null
      self = null   
    }       
  ]
  egress = [
    {
      description      = "allow all"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"] 
      prefix_list_ids = null
      security_groups = null
      self = null  
    }
  ]

  tags = {
    Name = "k3s-server-new-sg"
  }
}

resource "aws_security_group_rule" "server-ingress1" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  #cidr_blocks       = [aws_vpc.example.cidr_block]
  #ipv6_cidr_blocks  = [aws_vpc.example.ipv6_cidr_block]
  security_group_id = aws_security_group.k3s_server_new.id
  source_security_group_id = aws_security_group.k3s_server_new.id 

}

resource "aws_security_group_rule" "server-ingress2" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  #cidr_blocks       = [aws_vpc.example.cidr_block]
  #ipv6_cidr_blocks  = [aws_vpc.example.ipv6_cidr_block]
  security_group_id = aws_security_group.k3s_server_new.id
  source_security_group_id = aws_security_group.k3s_agent_new.id 

}

resource "aws_security_group" "k3s_agent_new" {
  name        = "k3s-agent-new"
  #description = "Allow TLS inbound traffic"
  vpc_id      = aws_default_vpc.default.id

  ingress = [
    {    
      description      = "for ssh"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"] 
      prefix_list_ids = null
      security_groups = null
      self = null
      #security_group_id = aws_security_group.k3s_server.id      
    },
    {    
      description      = "for http"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"] 
      prefix_list_ids = null
      security_groups = null
      self = null
      #security_group_id = aws_security_group.k3s_server.id      
    },
    {    
      description      = "for http2"
      from_port        = 8080
      to_port          = 8080
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"] 
      prefix_list_ids = null
      security_groups = null
      self = null
      #security_group_id = aws_security_group.k3s_server.id      
    },
    {    
      description      = "for https"
      from_port        = 443
      to_port          = 443
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"] 
      prefix_list_ids = null
      security_groups = null
      self = null
      #security_group_id = aws_security_group.k3s_server.id      
    },
    {    
      description      = "for k8s"
      from_port        = 6443
      to_port          = 6443
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"] 
      prefix_list_ids = null
      security_groups = null
      self = null
      #security_group_id = aws_security_group.k3s_server.id      
    },
    {      
      description      = "all"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"] 
      prefix_list_ids = null
      security_groups = null
      self = null   
    }
  ]

  egress = [
    {
      description = null
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids = null
      security_groups = null
      self = null  

    }
  ]

  tags = {
    Name = "k3s-agent-new-sg"
  }
}

resource "aws_security_group_rule" "agent-ingress1" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  #cidr_blocks       = [aws_vpc.example.cidr_block]
  #ipv6_cidr_blocks  = [aws_vpc.example.ipv6_cidr_block]
  security_group_id = aws_security_group.k3s_agent_new.id
  source_security_group_id = aws_security_group.k3s_agent_new.id 

}

resource "aws_security_group_rule" "agent-ingress2" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  #cidr_blocks       = [aws_vpc.example.cidr_block]
  #ipv6_cidr_blocks  = [aws_vpc.example.ipv6_cidr_block]
  security_group_id = aws_security_group.k3s_agent_new.id
  source_security_group_id = aws_security_group.k3s_server_new.id
}
#
