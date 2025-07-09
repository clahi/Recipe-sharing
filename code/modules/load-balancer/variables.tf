variable "subnet_ids" {
  description = "The subnet IDS to deploy to"
  type = list(string)
}

variable "alb_name" {
  description = "The name to use for the ALB"
  type = string
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  default     = 80
}

variable "vpc_id" {
  description = "The vpc to deploy the resources"
  type = string
}