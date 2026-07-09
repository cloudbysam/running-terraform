provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "main_server" {
    ami = "ami-002192a70217ac181"
    instance_type = "t2.micro"

    user_data_base64 = base64encode(<<-EOF
    #!/bin/bash
    sudo apt update -y
    sudo apt install -y busybox
        mkdir -p /var/www
        echo "Hello, World from Terraform." > /var/www/index.html
        nohup busybox httpd -f -p 8080 -h /var/www &
        EOF
        )
    
    user_data_replace_on_change = true

    tags = {
      Name = "main-server"
    }
}