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

variable "custom_tags" {
  description = "Custom tags to set on the instances in the ASG"
  type        = map(string)
  default     = {}
}

variable "enable_autoscaling" {
  description = "if set to True, enable auto scaling."
  type        = bool
}

variable "ami" {
  description = "The AMI to run in the cluster."
  type        = string
  default     = "ami-0b6d9d3d33ba97d99"
}

variable "server_text" {
  description = "The text the web server should return."
  type        = string
  default     = "Hello, World"
}

variable "enable_route53" {
  type        = bool
  description = "If true, create Route 53 DNS records and hosted zones for the cluster"
}

variable "domain_name" {
  type        = string
  default     = ""
  description = "The domain name purchased from NameCheap."
}