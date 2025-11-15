variable "instance_type" {}
variable "instance_keypair" {}
variable "vpc_id" {}
variable "public_subnets" { type = list(string) }
variable "tags" { type = map(string) }
variable "project_name" {}
variable "bastion_sg_name" { type = string }
variable "bastion_name" { type = string }