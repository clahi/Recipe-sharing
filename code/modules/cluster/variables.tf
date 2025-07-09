variable "cluster_name" {
  description = "The name to use for all the cluster resources."
  type = string
}

variable "instance_type" {
  description = "THe type of EC2 instances to run."
  type = string
}

variable "min_size" {
  description = "The minimum number of EC2 instances in the ASG"
  type = number
}

variable "max_size" {
  description = "The maximum number of EC2 Instances in the ASG"
  type = number
}

variable "ami" {
  description = "The AMI to run in the cluster"
  type = string
  default = "ami-0866a3c8686eaeeba"
}

variable "subnet_ids" {
  description = "The subnet IDS to deploy to"
  type = list(string)
}

variable "target_group_arns" {
  description = "The ARNs of ELB target groups in which to register Instances"
  type = list(string)
  default = [ ]
}

variable "health_check_type" {
  description = "the type of health check to perform. Must be one of: EC2, ELB."
  type = string
  default = "EC2"
}

variable "user_data" {
  description = "The User Data script to run in each Intance at boot."
  type = string
  default = null
}