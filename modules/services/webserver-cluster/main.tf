resource "aws_launch_template" "main_server" {
  name_prefix   = "${var.cluster_name}-"
  image_id      = "ami-0b6d9d3d33ba97d99"
  instance_type = var.instance_type

  network_interfaces {
    security_groups             = [aws_security_group.network.id]
    associate_public_ip_address = true
  }

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    DB_ADDRESS  = data.terraform_remote_state.db.outputs.address,
    DB_PORT     = data.terraform_remote_state.db.outputs.port,
    SERVER_PORT = var.server_port
  }))

  # Required when using a launch configuration with an auto scaling group.
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "network" {
  name = "${var.cluster_name}-network"
}

resource "aws_security_group_rule" "ingress" {
  type              = "ingress"
  security_group_id = aws_security_group.network.id
  
  from_port         = var.server_port
  to_port           = var.server_port
  protocol          = local.tcp_protocol
  cidr_blocks       = local.all_ips
}

resource "aws_autoscaling_group" "auto-scale" {
  # Explicitly depend on the launch templates name so each time it's replaced, this ASG is also replaced"
  name = "${var.cluster_name}-${aws_launch_template.main_server.latest_version}"

  desired_capacity    = var.desired_capacity
  max_size            = var.max_size
  min_size            = var.min_size
  vpc_zone_identifier = data.aws_subnets.default.ids

  # Wait for at least this many instances to pass health checks before considering the ASG deployment complete
  min_elb_capacity = var.min_size

  launch_template {
    id      = aws_launch_template.main_server.id
    version = "$Latest"
  }

  # When replacing this ASG, create the replacement first, and only delete the original after
  lifecycle {
    create_before_destroy = true
  }

  # Links the ASG dynamically to the ALB target group
  target_group_arns = [aws_lb_target_group.asg.arn]

  # Changes health check tracking from standard EC2 to the Load Balancer
  health_check_type         = "ELB"
  health_check_grace_period = 60

  capacity_rebalance = true

  tag {
    key                 = "Name"
    value               = "${var.cluster_name}-server"
    propagate_at_launch = true
  }
}

resource "aws_lb" "load-balancer" {
  name               = "${var.cluster_name}-terraform-load"
  load_balancer_type = "application"
  subnets            = data.aws_subnets.default.ids
  security_groups    = [aws_security_group.alb.id]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.load-balancer.arn
  port              = local.http_port
  protocol          = "HTTP"

  # By default return a simple 404 page
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}

resource "aws_security_group" "alb" {
  name = "${var.cluster_name}-alb-security-group"
}

resource "aws_security_group_rule" "allow_http_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.alb.id

  from_port   = local.http_port
  to_port     = local.http_port
  protocol    = local.tcp_protocol
  cidr_blocks = local.all_ips
}

resource "aws_security_group_rule" "allow_all_outbound" {
  type              = "egress"
  security_group_id = aws_security_group.alb.id

  from_port   = local.any_port
  to_port     = local.any_port
  protocol    = local.any_protocol
  cidr_blocks = local.all_ips
}

resource "aws_lb_target_group" "asg" {
  name     = "${var.cluster_name}-target-group"
  port     = var.server_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener_rule" "listener-rule" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}


data "terraform_remote_state" "db" {
  backend = "s3"

  config = {
    bucket = var.db_remote_state_bucket
    key    = var.db_remote_state_key
    region = "us-east-1"
  }
}