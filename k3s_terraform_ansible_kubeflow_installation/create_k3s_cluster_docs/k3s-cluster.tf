terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.59.0"
    }
    gitlab = {
      source = "gitlabhq/gitlab"
      version = "~> 3.0"
    }  
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "<= 2.0.0"
    }
    rancher2 = {
      source = "rancher/rancher2"
      version = ">= 1.10.0" 
    }
  }
}


# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
#  access_key = var.access_key
#  secret_key = var.secret_key
}


# create k3s server instance
resource "aws_instance" "master" {
  depends_on = [module.ssh_key_pair]
  ami           = "ami-03cf61cbdcd1e8730"
  # cluster-asg role for server node
  iam_instance_profile = "k8s-cluster-asg-master-role" 
  key_name      = module.ssh_key_pair.key_name
  #security_groups = ["k3s-server"]
  vpc_security_group_ids = [ aws_security_group.k3s_server_new.id ]
  instance_type = "t3a.large"
    user_data = base64encode(templatefile("${path.module}/server-userdata.tmpl", {
    token = random_password.k3s_cluster_secret.result,
  }))
  root_block_device {
  #  iops = gp3
    volume_size = 20
  #  volume_type = gp3
  }
  tags = {
    Name = "k3sServer"
    env = "dev"
  }
}  

# to create key pem for instances 
module "ssh_key_pair" {
  source = "cloudposse/key-pair/aws"
  ## Cloud Posse recommends pinning every module to a specific version
  ## version     = "x.x.x"
  namespace             = "eg"
  stage                 = "prod"
  name                  = "project_x"
  ssh_public_key_path   = "./pem_key"
  generate_ssh_key      = "true"
  private_key_extension = ".pem"
  public_key_extension  = ".pub"
}

## if you want to launch only one agent-node without asg use this resource
#resource "aws_instance" "worker" {
  #ami           = "ami-0858c0676cbfe16bd"
  #root_block_device {
      #volume_size = 8
  #}
  ##count         = var.a_num_servers
  #key_name      = module.ssh_key_pair.key_name
  #vpc_security_group_ids = [ aws_security_group.k3s_agent.id ]
  ##placement_group  = aws_placement_group.k3s.id
  #instance_type = "t3a.nano"
  #user_data = base64encode(templatefile("${path.module}/agent-userdata.tmpl", {
    #host = aws_instance.master.private_ip, 
    #token = random_password.k3s_cluster_secret.result
  #}))
  #depends_on = [ aws_instance.master ]

  #tags = {
    #Name = "k3sAgent"
  #}
#}

####   MASTER LAUNCH TEMPLATE and ASG

resource "aws_launch_template" "master" {
  image_id      = "ami-03cf61cbdcd1e8730"
  instance_type = "t3a.large"
  # cluster-asg role for agent node
  iam_instance_profile {
    name = "k8s-cluster-asg-master-role"
  }
  #security_group_names = ["k3s-agent"]
  
  
  
  vpc_security_group_ids = [ aws_security_group.k3s_server_new.id ] 
  key_name      = module.ssh_key_pair.key_name
  user_data = base64encode(templatefile("master-userdata.tmpl", {
    host = aws_instance.master.private_ip,
    token = random_password.k3s_cluster_secret.result
 }))
   depends_on = [ aws_instance.master ]
   tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "MasterNode-k3s"
    }
  }
}

#This defines the group as containing 1-10 instances and points at earlier launch template as the way to launch new instances. The tag is propogated to any launched instance at launch.
resource "aws_autoscaling_group" "master_k3s" {
  name                = "mlops-asg-master-k3s"
  capacity_rebalance  = true #Capacity Rebalancing helps you maintain workload availability by proactively augmenting your fleet with a new Spot Instance before a running instance is interrupted by EC2.
  desired_capacity    = 0
  max_size            = 3
  min_size            = 0
  health_check_grace_period = 300
  health_check_type         = "EC2"
  vpc_zone_identifier = [ "subnet-02957de2e70d0ebe0", "subnet-091e0db9ba81cf194", "subnet-07317d4533f0896af", "subnet-057072f1cff1d3f97", "subnet-02ba9f74464a4fadc", "subnet-0016942c4155e3493"]

  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity                  = 2
      on_demand_percentage_above_base_capacity = 0
      spot_allocation_strategy                 = "capacity-optimized" # automatically launches Spot Instances into the most available pools by looking at real-time capacity data and predicting which are the most available.By offering the possibility of fewer interruptions, the capacity-optimized strategy can lower the overall cost of your workload.
    }

    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.master.id
      }   
      override {
        instance_type     = "t3a.large"
        weighted_capacity = "1"
      }
      override {
        instance_type     = "t3.large"
        weighted_capacity = "1"
      }
    }
  }
  depends_on = [ aws_launch_template.master ]
  tag {
        key = "Name"
        value = "k3sMaster"
        propagate_at_launch = true
    }
  tag {
    key                 = "k8s.io/cluster-autoscaler/enabled"
    value               = "mlops"
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/cluster"
    value               = "mlops"
    propagate_at_launch = true
  } 
}

resource "aws_autoscaling_policy" "agents-scale-up-master" {
    name = "agents-scale-up-master"
    scaling_adjustment = 1
    adjustment_type = "ChangeInCapacity"
    cooldown = 60
    autoscaling_group_name = aws_autoscaling_group.master_k3s.name
}

resource "aws_autoscaling_policy" "agents-scale-down-master" {
    name = "agents-scale-down-master"
    scaling_adjustment = -1
    adjustment_type = "ChangeInCapacity"
    cooldown = 120
    autoscaling_group_name = aws_autoscaling_group.master_k3s.name
}

resource "aws_cloudwatch_metric_alarm" "cpu-high-1" {
    alarm_name = "cpu-util-high-agents-burst"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods = "2"
    metric_name = "CPUUtilization"
    namespace = "AWS/EC2"
    period = "60"
    statistic = "Average"
    threshold = "40"
    alarm_description = "This metric monitors ec2 cpu for high utilization on agent hosts"
    alarm_actions = [aws_autoscaling_policy.agents-scale-up-master.arn]
    dimensions = {
        AutoScalingGroupName = aws_autoscaling_group.master_k3s.name
    }
}



#####WORKER_FOR_K3s_SPOT LAUNCH TEMPLATE and ASG

## If you want to use auto scaling for worker nodes use this launch tamplate:
resource "aws_launch_template" "spotworker_k3s" {
  image_id      = "ami-03cf61cbdcd1e8730"
  instance_type = "t3a.large"
  # cluster-asg role for agent node
  iam_instance_profile {
    name = "k8s-cluster-asg-worker-role"
  }
  #security_group_names = ["k3s-agent"]
  
  
  
  vpc_security_group_ids = [ aws_security_group.k3s_agent_new.id ] 
  key_name      = module.ssh_key_pair.key_name
  user_data = base64encode(templatefile("agent-userdata.tmpl", {
    host = aws_instance.master.private_ip,
    token = random_password.k3s_cluster_secret.result
 }))
   depends_on = [ aws_instance.master ]
   tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "AgentNode-k3s"
    }
  }
}

#This defines the group as containing 1-10 instances and points at earlier launch template as the way to launch new instances. The tag is propogated to any launched instance at launch.
resource "aws_autoscaling_group" "spotworker_k3s" {
  name                = "mlops-asg-spotworker-k3s"
  capacity_rebalance  = true #Capacity Rebalancing helps you maintain workload availability by proactively augmenting your fleet with a new Spot Instance before a running instance is interrupted by EC2.
  desired_capacity    = 0
  max_size            = 5
  min_size            = 0
  health_check_grace_period = 300
  health_check_type         = "EC2"
  vpc_zone_identifier = [ "subnet-02957de2e70d0ebe0", "subnet-091e0db9ba81cf194", "subnet-07317d4533f0896af", "subnet-057072f1cff1d3f97", "subnet-02ba9f74464a4fadc", "subnet-0016942c4155e3493"]

  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity                  = 0
      on_demand_percentage_above_base_capacity = 0
      spot_allocation_strategy                 = "capacity-optimized" # automatically launches Spot Instances into the most available pools by looking at real-time capacity data and predicting which are the most available.By offering the possibility of fewer interruptions, the capacity-optimized strategy can lower the overall cost of your workload.
    }

    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.spotworker_k3s.id
      }   
      override {
        instance_type     = "t3a.large"
        weighted_capacity = "1"
      }
      override {
        instance_type     = "t3.large"
        weighted_capacity = "1"
      }
    }
  }
  depends_on = [ aws_launch_template.spotworker_k3s ]
  tag {
        key = "Name"
        value = "k3sAgentworker"
        propagate_at_launch = true
    }
  tag {
    key                 = "k8s.io/cluster-autoscaler/enabled"
    value               = "mlops"
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/cluster"
    value               = "mlops"
    propagate_at_launch = true
  } 
}

resource "aws_autoscaling_policy" "agents-scale-up-worker-k3s" {
    name = "agents-scale-up-worker-k3s"
    scaling_adjustment = 1
    adjustment_type = "ChangeInCapacity"
    cooldown = 60
    autoscaling_group_name = aws_autoscaling_group.spotworker_k3s.name
}

resource "aws_autoscaling_policy" "agents-scale-down-worker-k3s" {
    name = "agents-scale-down-worker-k3s"
    scaling_adjustment = -1
    adjustment_type = "ChangeInCapacity"
    cooldown = 120
    autoscaling_group_name = aws_autoscaling_group.spotworker_k3s.name
}



resource "aws_cloudwatch_metric_alarm" "cpu-high-2" {
    alarm_name = "cpu-util-high-agents-burst-1"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods = "2"
    metric_name = "CPUUtilization"
    namespace = "AWS/EC2"
    period = "60"
    statistic = "Average"
    threshold = "40"
    alarm_description = "This metric monitors ec2 cpu for high utilization on agent hosts"
    alarm_actions = [aws_autoscaling_policy.agents-scale-up-worker-k3s.arn]
    dimensions = {
        AutoScalingGroupName = aws_autoscaling_group.spotworker_k3s.name
    }
}



#Creates the CloudWatch metric alarms. The first one triggers the scale up policy 
#when the group’s overall CPUutilization is >= 70% for 2 minute intervals.
#The second one triggers the scale down policy when the group’s overall CPU utilization is <= 2%.



######    LT and ASG for WORKER-one for DATA_SCIENCE 

resource "aws_launch_template" "spotworker-one" {
  image_id      = "ami-03cf61cbdcd1e8730"
  instance_type = "t3a.2xlarge"
  # cluster-asg role for agent node
  iam_instance_profile {
    name = "k8s-cluster-asg-worker-role"
  }
  vpc_security_group_ids = [ aws_security_group.k3s_agent_new.id ] 
  key_name      = module.ssh_key_pair.key_name
  user_data = base64encode(templatefile("agent-gr1-userdata.tmpl", {
    host = aws_instance.master.private_ip,
    token = random_password.k3s_cluster_secret.result
 }))
  depends_on = [ aws_instance.master ]
  tag_specifications {
    resource_type = "instance"
 
  
  tags = {
    Name = "AgentNode-one"
  }
  }
}

#This defines the group as containing 1-10 instances and points at earlier launch template as the way to launch new instances. The tag is propogated to any launched instance at launch.
resource "aws_autoscaling_group" "worker-one" {
  name                = "mlops-asg-workergroup-one"
  capacity_rebalance  = true #Capacity Rebalancing helps you maintain workload availability by proactively augmenting your fleet with a new Spot Instance before a running instance is interrupted by EC2.
  desired_capacity    = 0
  max_size            = 5
  min_size            = 0
  health_check_grace_period = 300
  health_check_type         = "EC2"
  vpc_zone_identifier = [ "subnet-02957de2e70d0ebe0", "subnet-091e0db9ba81cf194", "subnet-07317d4533f0896af", "subnet-057072f1cff1d3f97", "subnet-02ba9f74464a4fadc", "subnet-0016942c4155e3493"]
#instance capacity change
  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity                  = 0
      on_demand_percentage_above_base_capacity = 0
      spot_allocation_strategy                 = "capacity-optimized" # automatically launches Spot Instances into the most available pools by looking at real-time capacity data and predicting which are the most available.By offering the possibility of fewer interruptions, the capacity-optimized strategy can lower the overall cost of your workload.
    }

    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.spotworker-one.id
      }
      override {
        instance_type     = "t3a.2xlarge"
        weighted_capacity = "1"
      }
      override {
        instance_type     = "t3.2xlarge"
        weighted_capacity = "1"
      }
    }
  }
  depends_on = [ aws_launch_template.spotworker-one ]
   tag {
        key = "Name"
        value = "k3sAgentOne"
        propagate_at_launch = true
  }
  tag {
    key                 = "k8s.io/cluster-autoscaler/enabled"
    value               = "mlops"
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/cluster"
    value               = "mlops"
    propagate_at_launch = true
  } 
}


resource "aws_autoscaling_policy" "agents-scale-up-worker-1" {
    name = "agents-scale-up-worker-1"
    scaling_adjustment = 1
    adjustment_type = "ChangeInCapacity"
    cooldown = 60
    autoscaling_group_name = aws_autoscaling_group.worker-one.name
}

resource "aws_autoscaling_policy" "agents-scale-down-worker-1" {
    name = "agents-scale-down-worker-1"
    scaling_adjustment = -1
    adjustment_type = "ChangeInCapacity"
    cooldown = 120
    autoscaling_group_name = aws_autoscaling_group.worker-one.name
}



resource "aws_cloudwatch_metric_alarm" "cpu-high-3" {
    alarm_name = "cpu-util-high-agents-burst-2"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods = "2"
    metric_name = "CPUUtilization"
    namespace = "AWS/EC2"
    period = "60"
    statistic = "Average"
    threshold = "50"
    alarm_description = "This metric monitors ec2 cpu for high utilization on agent hosts"
    alarm_actions = [aws_autoscaling_policy.agents-scale-up-worker-1.arn]
    dimensions = {
        AutoScalingGroupName = aws_autoscaling_group.worker-one.name
    }
}


######    LT and ASG for WORKER-two for DATA_SCIENCE 


resource "aws_launch_template" "spotworker-two" {
  image_id      = "ami-03cf61cbdcd1e8730"
  instance_type = "c5a.4xlarge"
  # cluster-asg role for agent node
  iam_instance_profile {
    name = "k8s-cluster-asg-worker-role"
  }
  #security_group_names = ["k3s-agent"]
  
  
  
  vpc_security_group_ids = [ aws_security_group.k3s_agent_new.id ] 
  key_name      = module.ssh_key_pair.key_name
  user_data = base64encode(templatefile("agent-gr2-userdata.tmpl", {
    host = aws_instance.master.private_ip,
    token = random_password.k3s_cluster_secret.result
 }))
   depends_on = [ aws_instance.master ]
   tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "AgentNode-two"
    }
  }
}

#This defines the group as containing 1-10 instances and points at earlier launch template as the way to launch new instances. The tag is propogated to any launched instance at launch.
resource "aws_autoscaling_group" "worker-two" {
  name                = "mlops-asg-spotworker-two"
  capacity_rebalance  = true #Capacity Rebalancing helps you maintain workload availability by proactively augmenting your fleet with a new Spot Instance before a running instance is interrupted by EC2.
  desired_capacity    = 0
  max_size            = 5
  min_size            = 0
  health_check_grace_period = 300
  health_check_type         = "EC2"
  vpc_zone_identifier = [ "subnet-02957de2e70d0ebe0", "subnet-091e0db9ba81cf194", "subnet-07317d4533f0896af", "subnet-057072f1cff1d3f97", "subnet-02ba9f74464a4fadc", "subnet-0016942c4155e3493"]

  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity                  = 0
      on_demand_percentage_above_base_capacity = 0
      spot_allocation_strategy                 = "capacity-optimized" # automatically launches Spot Instances into the most available pools by looking at real-time capacity data and predicting which are the most available.By offering the possibility of fewer interruptions, the capacity-optimized strategy can lower the overall cost of your workload.
    }

    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.spotworker-two.id
      }   
      override {
        instance_type     = "c5a.4xlarge"
        weighted_capacity = "1"
      }
      override {
        instance_type     = "c6a.4xlarge"
        weighted_capacity = "1"
      }
    }
  }
  depends_on = [ aws_launch_template.spotworker-two ]
  tag {
        key = "Name"
        value = "k3sAgenttwo"
        propagate_at_launch = true
    }
  tag {
    key                 = "k8s.io/cluster-autoscaler/enabled"
    value               = "mlops"
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/cluster"
    value               = "mlops"
    propagate_at_launch = true
  } 
}

resource "aws_autoscaling_policy" "agents-scale-up-worker-2" {
    name = "agents-scale-up-worker-2"
    scaling_adjustment = 1
    adjustment_type = "ChangeInCapacity"
    cooldown = 60
    autoscaling_group_name = aws_autoscaling_group.worker-two.name
}

resource "aws_autoscaling_policy" "agents-scale-down-worker-2" {
    name = "agents-scale-down-worker-2"
    scaling_adjustment = -1
    adjustment_type = "ChangeInCapacity"
    cooldown = 120
    autoscaling_group_name = aws_autoscaling_group.worker-two.name
}

resource "aws_cloudwatch_metric_alarm" "cpu-high-4" {
    alarm_name = "cpu-util-high-agents-4"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods = "2"
    metric_name = "CPUUtilization"
    namespace = "AWS/EC2"
    period = "60"
    statistic = "Average"
    threshold = "70"
    alarm_description = "This metric monitors ec2 cpu for high utilization on agent hosts"
    alarm_actions = [aws_autoscaling_policy.agents-scale-up-worker-2.arn]
    dimensions = {
        AutoScalingGroupName = aws_autoscaling_group.worker-two.name
    }
}

######    LT and ASG for WORKER-three for DATA_SCIENCE 


resource "aws_launch_template" "spotworker-three" {
  image_id      = "ami-03cf61cbdcd1e8730"
  instance_type = "c5a.8xlarge"
  # cluster-asg role for agent node
  iam_instance_profile {
    name = "k8s-cluster-asg-worker-role"
  }
  #security_group_names = ["k3s-agent"]
  
  
  
  vpc_security_group_ids = [ aws_security_group.k3s_agent_new.id ] 
  key_name      = module.ssh_key_pair.key_name
  user_data = base64encode(templatefile("agent-gr3-userdata.tmpl", {
    host = aws_instance.master.private_ip,
    token = random_password.k3s_cluster_secret.result
 }))
   depends_on = [ aws_instance.master ]
   tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "AgentNode-three"
    }
  }
}

#This defines the group as containing 1-10 instances and points at earlier launch template as the way to launch new instances. The tag is propogated to any launched instance at launch.
resource "aws_autoscaling_group" "worker-three" {
  name                = "mlops-asg-spotworker-three"
  capacity_rebalance  = true #Capacity Rebalancing helps you maintain workload availability by proactively augmenting your fleet with a new Spot Instance before a running instance is interrupted by EC2.
  desired_capacity    = 0
  max_size            = 5
  min_size            = 0
  health_check_grace_period = 300
  health_check_type         = "EC2"
  vpc_zone_identifier = [ "subnet-02957de2e70d0ebe0", "subnet-091e0db9ba81cf194", "subnet-07317d4533f0896af", "subnet-057072f1cff1d3f97", "subnet-02ba9f74464a4fadc", "subnet-0016942c4155e3493"]

  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity                  = 0
      on_demand_percentage_above_base_capacity = 0
      spot_allocation_strategy                 = "capacity-optimized" # automatically launches Spot Instances into the most available pools by looking at real-time capacity data and predicting which are the most available.By offering the possibility of fewer interruptions, the capacity-optimized strategy can lower the overall cost of your workload.
    }

    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.spotworker-three.id
      }   
      override {
        instance_type     = "c5a.8xlarge"
        weighted_capacity = "1"
      }
      override {
        instance_type     = "c6a.8xlarge"
        weighted_capacity = "1"
      }
    }
  }
  depends_on = [ aws_launch_template.spotworker-three ]
  tag {
        key = "Name"
        value = "k3sAgentthree"
        propagate_at_launch = true
    }
  tag {
    key                 = "k8s.io/cluster-autoscaler/enabled"
    value               = "mlops"
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/cluster"
    value               = "mlops"
    propagate_at_launch = true
  } 
}

resource "aws_autoscaling_policy" "agents-scale-up-worker-3" {
    name = "agents-scale-up-worker-3"
    scaling_adjustment = 1
    adjustment_type = "ChangeInCapacity"
    cooldown = 60
    autoscaling_group_name = aws_autoscaling_group.worker-three.name
}

resource "aws_autoscaling_policy" "agents-scale-down-worker-3" {
    name = "agents-scale-down-worker-3"
    scaling_adjustment = -1
    adjustment_type = "ChangeInCapacity"
    cooldown = 120
    autoscaling_group_name = aws_autoscaling_group.worker-three.name
}

resource "aws_cloudwatch_metric_alarm" "cpu-high-5" {
    alarm_name = "cpu-util-high-agents-5"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods = "2"
    metric_name = "CPUUtilization"
    namespace = "AWS/EC2"
    period = "60"
    statistic = "Average"
    threshold = "70"
    alarm_description = "This metric monitors ec2 cpu for high utilization on agent hosts"
    alarm_actions = [aws_autoscaling_policy.agents-scale-up-worker-3.arn]
    dimensions = {
        AutoScalingGroupName = aws_autoscaling_group.worker-three.name
    }
}
######    LT and ASG for WORKER-four for DATA_SCIENCE 



resource "aws_launch_template" "spotworker-four" {
  image_id      = "ami-03cf61cbdcd1e8730"
  instance_type = "r5a.4xlarge"
  # cluster-asg role for agent node
  iam_instance_profile {
    name = "k8s-cluster-asg-worker-role"
  }
  #security_group_names = ["k3s-agent"]
  
  
  
  vpc_security_group_ids = [ aws_security_group.k3s_agent_new.id ] 
  key_name      = module.ssh_key_pair.key_name
  user_data = base64encode(templatefile("agent-gr4-userdata.tmpl", {
    host = aws_instance.master.private_ip,
    token = random_password.k3s_cluster_secret.result
 }))
   depends_on = [ aws_instance.master ]
   tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "AgentNode-four"
    }
  }
}
#This defines the group as containing 1-10 instances and points at earlier launch template as the way to launch new instances. The tag is propogated to any launched instance at launch.
resource "aws_autoscaling_group" "worker-four" {
  name                = "mlops-asg-spotworker-four"
  capacity_rebalance  = true #Capacity Rebalancing helps you maintain workload availability by proactively augmenting your fleet with a new Spot Instance before a running instance is interrupted by EC2.
  desired_capacity    = 0
  max_size            = 5
  min_size            = 0
  health_check_grace_period = 300
  health_check_type         = "EC2"
  vpc_zone_identifier = [ "subnet-02957de2e70d0ebe0", "subnet-091e0db9ba81cf194", "subnet-07317d4533f0896af", "subnet-057072f1cff1d3f97", "subnet-02ba9f74464a4fadc", "subnet-0016942c4155e3493"]

  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity                  = 0
      on_demand_percentage_above_base_capacity = 0
      spot_allocation_strategy                 = "capacity-optimized" # automatically launches Spot Instances into the most available pools by looking at real-time capacity data and predicting which are the most available.By offering the possibility of fewer interruptions, the capacity-optimized strategy can lower the overall cost of your workload.
    }

    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.spotworker-four.id
      }   
      override {
        instance_type     = "r5a.4xlarge"
        weighted_capacity = "1"
      }
      override {
        instance_type     = "r5.4xlarge"
        weighted_capacity = "1"
      }
    }
  }
  depends_on = [ aws_launch_template.spotworker-four ]
  tag {
        key = "Name"
        value = "k3sAgentfour"
        propagate_at_launch = true
    }
  tag {
    key                 = "k8s.io/cluster-autoscaler/enabled"
    value               = "mlops"
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/cluster"
    value               = "mlops"
    propagate_at_launch = true
  } 
}

resource "aws_autoscaling_policy" "agents-scale-up-worker-4" {
    name = "agents-scale-up-worker-4"
    scaling_adjustment = 1
    adjustment_type = "ChangeInCapacity"
    cooldown = 60
    autoscaling_group_name = aws_autoscaling_group.worker-four.name
}
resource "aws_autoscaling_policy" "agents-scale-down-worker-4" {
    name = "agents-scale-down-worker-4"
    scaling_adjustment = -1
    adjustment_type = "ChangeInCapacity"
    cooldown = 120
    autoscaling_group_name = aws_autoscaling_group.worker-four.name
}

resource "aws_cloudwatch_metric_alarm" "cpu-high-6" {
    alarm_name = "cpu-util-high-agents-6"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods = "2"
    metric_name = "CPUUtilization"
    namespace = "AWS/EC2"
    period = "60"
    statistic = "Average"
    threshold = "70"
    alarm_description = "This metric monitors ec2 cpu for high utilization on agent hosts"
    alarm_actions = [aws_autoscaling_policy.agents-scale-up-worker-4.arn]
    dimensions = {
        AutoScalingGroupName = aws_autoscaling_group.worker-four.name
    }
}

######    LT and ASG for WORKER-five for DATA_SCIENCE 



resource "aws_launch_template" "spotworker-five" {
  image_id      = "ami-03cf61cbdcd1e8730"
  instance_type = "m5a.8xlarge"
  # cluster-asg role for agent node
  iam_instance_profile {
    name = "k8s-cluster-asg-worker-role"
  }
  #security_group_names = ["k3s-agent"]
  
  
  
  vpc_security_group_ids = [ aws_security_group.k3s_agent_new.id ] 
  key_name      = module.ssh_key_pair.key_name
  user_data = base64encode(templatefile("agent-gr5-userdata.tmpl", {
    host = aws_instance.master.private_ip,
    token = random_password.k3s_cluster_secret.result
 }))
   depends_on = [ aws_instance.master ]
   tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "AgentNode-five"
    }
  }
}
#This defines the group as containing 1-10 instances and points at earlier launch template as the way to launch new instances. The tag is propogated to any launched instance at launch.
resource "aws_autoscaling_group" "worker-five" {
  name                = "mlops-asg-spotworker-five"
  capacity_rebalance  = true #Capacity Rebalancing helps you maintain workload availability by proactively augmenting your fleet with a new Spot Instance before a running instance is interrupted by EC2.
  desired_capacity    = 0
  max_size            = 5
  min_size            = 0
  health_check_grace_period = 300
  health_check_type         = "EC2"
  vpc_zone_identifier = [ "subnet-02957de2e70d0ebe0", "subnet-091e0db9ba81cf194", "subnet-07317d4533f0896af", "subnet-057072f1cff1d3f97", "subnet-02ba9f74464a4fadc", "subnet-0016942c4155e3493"]

  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity                  = 0
      on_demand_percentage_above_base_capacity = 0
      spot_allocation_strategy                 = "capacity-optimized" # automatically launches Spot Instances into the most available pools by looking at real-time capacity data and predicting which are the most available.By offering the possibility of fewer interruptions, the capacity-optimized strategy can lower the overall cost of your workload.
    }

    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.spotworker-five.id
      }   
      override {
        instance_type     = "m5a.8xlarge"
        weighted_capacity = "1"
      }
      override {
        instance_type     = "m6a.8xlarge"
        weighted_capacity = "1"
      }
    }
  }
  depends_on = [ aws_launch_template.spotworker-five ]
  tag {
        key = "Name"
        value = "k3sAgentfive"
        propagate_at_launch = true
    }
  tag {
    key                 = "k8s.io/cluster-autoscaler/enabled"
    value               = "mlops"
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/cluster"
    value               = "mlops"
    propagate_at_launch = true
  } 
}

resource "aws_autoscaling_policy" "agents-scale-up-worker-5" {
    name = "agents-scale-up-worker-5"
    scaling_adjustment = 1
    adjustment_type = "ChangeInCapacity"
    cooldown = 60
    autoscaling_group_name = aws_autoscaling_group.worker-five.name
}

resource "aws_autoscaling_policy" "agents-scale-down-worker-5" {
    name = "agents-scale-down-worker-5"
    scaling_adjustment = -1
    adjustment_type = "ChangeInCapacity"
    cooldown = 120
    autoscaling_group_name = aws_autoscaling_group.worker-five.name
}

resource "aws_cloudwatch_metric_alarm" "cpu-high-7" {
    alarm_name = "cpu-util-high-agents-7"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods = "2"
    metric_name = "CPUUtilization"
    namespace = "AWS/EC2"
    period = "60"
    statistic = "Average"
    threshold = "70"
    alarm_description = "This metric monitors ec2 cpu for high utilization on agent hosts"
    alarm_actions = [aws_autoscaling_policy.agents-scale-up-worker-5.arn]
    dimensions = {
        AutoScalingGroupName = aws_autoscaling_group.worker-five.name
    }
}


######    LT and ASG for WORKER-six for DATA_SCIENCE 


resource "aws_launch_template" "spotworker-six" {
  image_id      = "ami-03cf61cbdcd1e8730"
  instance_type = "m5a.16xlarge"
  # cluster-asg role for agent node
  iam_instance_profile {
    name = "k8s-cluster-asg-worker-role"
  }
  #security_group_names = ["k3s-agent"]
  
  
  
  vpc_security_group_ids = [ aws_security_group.k3s_agent_new.id ] 
  key_name      = module.ssh_key_pair.key_name
  user_data = base64encode(templatefile("agent-gr6-userdata.tmpl", {
    host = aws_instance.master.private_ip,
    token = random_password.k3s_cluster_secret.result
 }))
   depends_on = [ aws_instance.master ]
   tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "AgentNode-six"
    }
  }
}
#This defines the group as containing 1-10 instances and points at earlier launch template as the way to launch new instances. The tag is propogated to any launched instance at launch.
resource "aws_autoscaling_group" "worker-six" {
  name                = "mlops-asg-spotworker-six"
  capacity_rebalance  = true #Capacity Rebalancing helps you maintain workload availability by proactively augmenting your fleet with a new Spot Instance before a running instance is interrupted by EC2.
  desired_capacity    = 0
  max_size            = 5
  min_size            = 0
  health_check_grace_period = 300
  health_check_type         = "EC2"
  vpc_zone_identifier = [ "subnet-02957de2e70d0ebe0", "subnet-091e0db9ba81cf194", "subnet-07317d4533f0896af", "subnet-057072f1cff1d3f97", "subnet-02ba9f74464a4fadc", "subnet-0016942c4155e3493"]

  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity                  = 0
      on_demand_percentage_above_base_capacity = 0
      spot_allocation_strategy                 = "capacity-optimized" # automatically launches Spot Instances into the most available pools by looking at real-time capacity data and predicting which are the most available.By offering the possibility of fewer interruptions, the capacity-optimized strategy can lower the overall cost of your workload.
    }

    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.spotworker-six.id
      }   
      override {
        instance_type     = "m5a.16xlarge"
        weighted_capacity = "1"
      }
      override {
        instance_type     = "m6a.16xlarge"
        weighted_capacity = "1"
      }
    }
  }
  depends_on = [ aws_launch_template.spotworker-six ]
  tag {
        key = "Name"
        value = "k3sAgentsix"
        propagate_at_launch = true
    }
  tag {
    key                 = "k8s.io/cluster-autoscaler/enabled"
    value               = "mlops"
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/cluster"
    value               = "mlops"
    propagate_at_launch = true
  } 
}

resource "aws_autoscaling_policy" "agents-scale-up-worker-6" {
    name = "agents-scale-up-worker-6"
    scaling_adjustment = 1
    adjustment_type = "ChangeInCapacity"
    cooldown = 120
    autoscaling_group_name = aws_autoscaling_group.worker-six.name
}

resource "aws_autoscaling_policy" "agents-scale-down-worker-6" {
    name = "agents-scale-down-worker-6"
    scaling_adjustment = -1
    adjustment_type = "ChangeInCapacity"
    cooldown = 180
    autoscaling_group_name = aws_autoscaling_group.worker-six.name
}

resource "aws_cloudwatch_metric_alarm" "cpu-high-8" {
    alarm_name = "cpu-util-high-agents-8"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods = "2"
    metric_name = "CPUUtilization"
    namespace = "AWS/EC2"
    period = "60"
    statistic = "Average"
    threshold = "70"
    alarm_description = "This metric monitors ec2 cpu for high utilization on agent hosts"
    alarm_actions = [aws_autoscaling_policy.agents-scale-up-worker-6.arn]
    dimensions = {
      AutoScalingGroupName = aws_autoscaling_group.worker-six.name
    }
}




#creates A record to project DNS name
#resource "aws_route53_record" "dev" {
#  zone_id = "Z03929083ML58R93P6135"
#  name    = "kf.nioyatechai.com"
#  type    = "A"
#  ttl     = "300"
#  records = [aws_instance.master.public_ip]
#}

#resource "aws_cloudwatch_metric_alarm" "cpu-low" {
    #alarm_name = "cpu-util-low-agents"
    #comparison_operator = "LessThanOrEqualToThreshold"
    #evaluation_periods = "2"
    #metric_name = "CPUUtilization"
    #namespace = "AWS/EC2"
    #period = "60"
    #statistic = "Average"
    #threshold = "2"
    #alarm_description = "This metric monitors ec2 cpu for low utilization on agent hosts"
    #alarm_actions = [aws_autoscaling_policy.agents-scale-down.arn]
    #dimensions = {
        #AutoScalingGroupName = aws_autoscaling_group.workernode.name
    #}
#}

#resource "aws_cloudwatch_metric_alarm" "memory-high" {
    #alarm_name = "mem-util-high-agents"
    #comparison_operator = "GreaterThanOrEqualToThreshold"
    #evaluation_periods = "2"
    #metric_name = "mem_used_percent"
    #namespace = "AWS/EC2"
    #period = "60"
    #statistic = "Average"
    #threshold = "80"
    #alarm_description = "This metric monitors ec2 memory for high utilization on agent hosts"
    #alarm_actions = [aws_autoscaling_policy.agents-scale-up.arn]
    #dimensions = {
        #AutoScalingGroupName = aws_autoscaling_group.workernode.name
    #}
#}

#resource "aws_cloudwatch_metric_alarm" "memory-low" {
    #alarm_name = "mem-util-low-agents"
    #comparison_operator = "LessThanOrEqualToThreshold"
    #evaluation_periods = "3"
    #metric_name = "MemoryUtilization"
    #namespace = "AWS/EC2"
    #period = "180"
    #statistic = "Average"
    #threshold = "25"
    #alarm_description = "This metric monitors ec2 memory for low utilization on agent hosts"
    #alarm_actions = [aws_autoscaling_policy.agents-scale-down.arn]
    #dimensions = {
        #AutoScalingGroupName = aws_autoscaling_group.workernode.name
    #}
#}




#try to use g5.4xlarge



