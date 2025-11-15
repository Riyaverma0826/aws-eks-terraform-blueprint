variable "project_name" {
  type = string
}

variable "common_tags" {
  type = map(string)
}

variable "eks_admin_role_arn" {
  type = string
}

variable "eks_readonly_role_arn" {
  type = string
}

variable "eks_developer_role_arn" {
  type = string
}
