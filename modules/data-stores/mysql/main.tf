resource "aws_db_instance" "database" {
  engine              = "mysql"
  skip_final_snapshot = true

  identifier_prefix   = "${lower(var.db_name)}-instance-"
  db_name             = lower(var.db_name)
  allocated_storage   = var.allocated_storage
  instance_class      = var.instance_class
  username            = var.db_username
  password            = var.db_password
}