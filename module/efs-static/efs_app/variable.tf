variable "project_name" {
  type        = string
  description = "Project name prefix"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where EFS will be created"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block of VPC"
}

variable "private_subnets" {
  type        = list(string)
  description = "List of private subnet IDs"
}

variable "tags" {
  type        = map(string)
  description = "Common tags for all resources"
}
