provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "main_server" {
    ami = "ami-0b6d9d3d33ba97d99"
    instance_type = "t2.micro"
    key_name = "N.Virginia-key"
    vpc_security_group_ids = [ aws_security_group.network.id ]

    user_data_base64 = base64encode(<<-EOF
#!/bin/bash
sudo apt update -y
sudo apt install -y busybox
mkdir -p /var/www
echo "Hello, World from Terraform :) ." > /var/www/index.html
nohup busybox httpd -f -p ${var.server_port} -h /var/www &
EOF
    )
    
    user_data_replace_on_change = true

    tags = {
      Name = "main-server"
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

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type = number
  default = 8080
}

output "ec2-public-address" {
  value = aws_instance.main_server.public_ip
  description = "The public IP address of theweb server."
}