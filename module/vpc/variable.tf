variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "vpc_public_subnets" {
  description = "List of public subnet CIDRs"
  type        = list(string)
}

variable "vpc_private_subnets" {
  description = "List of private subnet CIDRs"
  type        = list(string)
}

variable "vpc_enable_nat_gateway" {
  description = "Whether to enable NAT Gateway"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
}
