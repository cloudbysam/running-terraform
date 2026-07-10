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

  launch_template {
    id      =  aws_launch_template.main_server.id
    version = "$Latest"
  }
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type = number
  default = 8080
}

output "ec2-public-address" {
  value = aws_instance.main_server.public_ip
  description = "The public IP address of theweb server."
}