variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 8080
}

variable "cluster_name" {
  description = "The name to use for the cluster resources."
  type        = string
}

variable "db_remote_state_bucket" {
  description = "The name of the S3 bucket for the database's remote state"
  type        = string
}

variable "db_remote_state_key" {
  description = "The path for the database's remote state in S3"
  type        = string
}

variable "instance_type" {
  description = "The type of EC2 instance to run..."
  type        = string
}

variable "min_size" {
  description = "The minimum number of EC2 instabces to run"
  type        = number
}

variable "max_size" {
  description = "The maximum number of EC2 instabces to run"
  type        = number
}

variable "desired_capacity" {
  description = "The desired number of EC2 instabces to run"
  type        = number
}