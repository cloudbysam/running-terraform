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
echo "Hello, World from Terraform :( ." > /var/www/index.html
nohup busybox httpd -f -p 8080 -h /var/www &
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
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

}