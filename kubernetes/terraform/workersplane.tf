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






resource "aws_autoscaling_group" "kf_worker_1" {
  name = "autoscale-ha-k8s-worker-kf-asg-1-${var.PROJECT_IDENTIFIER}"
  capacity_rebalance  = true #Capacity Rebalancing helps you maintain workload availability by proactively augmenting your fleet with a new Spot Instance before a running instance is interrupted by EC2.
  desired_capacity = 1
  max_size = 5
  min_size = 1
  default_cooldown = 100
  health_check_grace_period = 300
  health_check_type = "ELB"
  vpc_zone_identifier = [ "subnet-02957de2e70d0ebe0", "subnet-091e0db9ba81cf194", "subnet-07317d4533f0896af", "subnet-057072f1cff1d3f97", "subnet-02ba9f74464a4fadc", "subnet-0016942c4155e3493"]
  
  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity                  = 0
      on_demand_percentage_above_base_capacity = 0
      spot_allocation_strategy                 = "capacity-optimized" # automatically launches Spot Instances into the most available pools by looking at real-time capacity data and predicting which are the most available.By offering the possibility of fewer interruptions, the capacity-optimized strategy can lower the overall cost of your workload.
    }

    launch_template {
      launch_template_specification {
        id = aws_launch_template.launch_template_kf_worker_1.id
        version = aws_launch_template.launch_template_worker_kf_worker_1.latest_version
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
      key                 = "kubernetes.io/cluster/${var.PROJECT_IDENTIFIER}-kf-worker-1"
      value               = "owned"
      propagate_at_launch = true
    }

  tag {
        key = "Name"
        value = "kf_worker_1"
        propagate_at_launch = true
    }
}

resource "aws_launch_template" "launch_template_kf_worker_1" {
  name = "autoscale-ha-k8s-kf-worker-1-lt-${var.PROJECT_IDENTIFIER}"
  image_id = var.AMI_ID
  instance_type = "t3a.2xlarge"
  
  iam_instance_profile {
    name = module.iam2.worker_profile_name
  } 
  key_name = var.KEY_NAME
  depends_on = [aws_instance.kube-master]
  vpc_security_group_ids = [module.secgroup.mutual_sec_group_id, module.secgroup.workers_sec_group_id]
  user_data = filebase64("./agent-gr1-userdata.sh")
  
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
      Name = "kube-kf_worker-1-LT-${var.PROJECT_IDENTIFIER}"
      "kubernetes.io/cluster/${var.PROJECT_IDENTIFIER}" = "owned"
      Project = "autoscale-ha-k8s-${var.PROJECT_IDENTIFIER}"
      Plane = "workersplane-${var.PROJECT_IDENTIFIER}"
      Role = "worker${var.PROJECT_IDENTIFIER}"
    }
  }
}

resource "aws_autoscaling_policy" "agents-scale-up-kf-worker-1" {
    name = "agents-scale-up-kf-worker-1"
    scaling_adjustment = 1
    adjustment_type = "ChangeInCapacity"
    cooldown = 60
    autoscaling_group_name = aws_autoscaling_group.kf_worker_1.name
}

resource "aws_autoscaling_policy" "agents-scale-down-kf-worker-1" {
    name = "agents-scale-down-kf-worker-1"
    scaling_adjustment = -1
    adjustment_type = "ChangeInCapacity"
    cooldown = 120
    autoscaling_group_name = aws_autoscaling_group.kf_worker_1.name
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
    alarm_actions = [aws_autoscaling_policy.agents-scale-up-kf-worker-1.arn]
    dimensions = {
        AutoScalingGroupName = aws_autoscaling_group.kf_worker_1.name
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
