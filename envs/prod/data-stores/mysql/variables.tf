variable "db_username" {
  description = "The database administrator username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "The database administrator password"
  type        = string
  sensitive   = true
}