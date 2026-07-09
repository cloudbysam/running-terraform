provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "main_server" {
    ami = "ami-002192a70217ac181"
    instance_type = "t2.micro"

    tags = {
      Name = "main-server"
    }
}