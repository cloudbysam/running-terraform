variable "db_name" {
  description = "The name of the database schema"
  type = string
}

variable "allocated_storage" {
  description = "The storage size in gigabytes"
  type = number
}

variable "instance_class" {
  description = "The compute size (e.g., db.t3.micro)"
  type = string
}

variable "db_username" {
  description = "The administrator username"
  type = string
  sensitive = true
}

variable "db_password" {
  description = "The administrator password"
  type = string
  sensitive = true
}