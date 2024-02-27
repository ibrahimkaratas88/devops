
resource "aws_alb_target_group" "app-lb-tg" {
  name = "phonebook-lb-tg"
  port = 80
  protocol = "HTTP"
  vpc_id = data.aws_vpc.selected.id
  target_type = "instance"
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 3
  }
}


resource "aws_launch_template" "asg-lt" {
  name = "phonebook-lt"
  image_id = data.aws_ami.amazon-linux-2.id
  instance_type = "t2.micro"
  key_name = "ibrahim"
  vpc_security_group_ids = [aws_security_group.server-sg.id]
  user_data = filebase64("user-data.sh")
  depends_on = [github_repository_file.dbendpoint]
  tag_specifications {
    resource_type = "instance"
    tags = {
        Name = "Web Server of Phonebook App"
    }
  }
}

resource "aws_autoscaling_group" "app-asg" {
    name = "phonebook-asg"
    desired_capacity = 2
    max_size = 3
    min_size = 2
    health_check_grace_period = 300
    health_check_type = "ELB"
    target_group_arns = [aws_alb_target_group.app-lb-tg.arn]
    vpc_zone_identifier = aws_alb.app-lb.subnets
    launch_template {
      id = aws_launch_template.asg-lt.id
      version = aws_launch_template.asg-lt.latest_version
    }
}
