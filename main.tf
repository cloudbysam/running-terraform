provider "aws" {
  region = "us-east-1"
}

resource "aws_launch_template" "main_server" {
    image_id = "ami-0b6d9d3d33ba97d99"
    instance_type = "t2.micro"

    network_interfaces {
      security_groups =  [ aws_security_group.network.id ]
      associate_public_ip_address = true
    }

    user_data = base64encode(<<-EOF
#!/bin/bash
sudo apt update -y
sudo apt install -y busybox
mkdir -p /var/www
echo "Hello, World from Terraform :) ." > /var/www/index.html
nohup busybox httpd -f -p ${var.server_port} -h /var/www &
EOF
    )

# Required when using a launch configuration with an auto scaling group.
lifecycle {
    create_before_destroy = true
  }    
}

resource "aws_security_group" "network" {
  name = "inbound-network"

  ingress  {
    from_port = var.server_port
    to_port = var.server_port
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

}

resource "aws_autoscaling_group" "auto-scale" {
  desired_capacity   = 2
  max_size           = 4
  min_size           = 2
  vpc_zone_identifier = data.aws_subnets.default.ids

  launch_template {
    id      =  aws_launch_template.main_server.id
    version = "$Latest"
  }

  # Links the ASG dynamically to the ALB target group
  target_group_arns = [ aws_lb_target_group.asg.arn ]
  
  # Changes health check tracking from standard EC2 to the Load Balancer
  health_check_type = "ELB"
  health_check_grace_period = 300
  
  tag {
    key = "Name"
    value = "terraform-server"
    propagate_at_launch = true
  }
}

resource "aws_lb" "load-balancer" {
  name = "terraform-load"
  load_balancer_type = "application"
  subnets = data.aws_subnets.default.ids
  security_groups = [ aws_security_group.alb.id ]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.load-balancer.arn
  port = 80
  protocol = "HTTP"

  # By default return a simple 404 page
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code = 404
    }
  }
}

resource "aws_security_group" "alb" {
  name = "alb-security-group"

  # Allow inbound HTTP requests
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

   # Allow all outbound requests
   egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

}

resource "aws_lb_target_group" "asg" {
  name = "terraform-target-group"
  port = var.server_port
  protocol = "HTTP"
  vpc_id = data.aws_vpc.default.id

  health_check {
    path = "/"
    protocol = "HTTP"
    matcher = "204"
    interval = 15
    timeout = 3
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener_rule" "listener-rule" {
  listener_arn = aws_lb_listener.http.arn
  priority = 100

  condition {
    path_pattern {
      values = [ "*" ]
    }
  }

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type = number
  default = 8080
}

output "alb-dns-name" {
  value = aws_lb.load-balancer.dns_name
  description = "The domain name of the load balancer."
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name = "vpc-id"
    values = [ data.aws_vpc.default.id ]
  }
}