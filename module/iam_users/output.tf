output "admin_user_name" {
  value = aws_iam_user.admin_user.name
}

output "basic_user_name" {
  value = aws_iam_user.basic_user.name
}
