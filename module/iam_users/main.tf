###############################################
# IAM USERS, GROUPS & POLICIES (NO ROLES HERE)
###############################################

###############
# ADMIN USER
###############
resource "aws_iam_user" "admin_user" {
  name          = "${var.project_name}-eksadmin1"
  path          = "/"
  force_destroy = true
  tags          = var.common_tags
}

resource "aws_iam_user_policy_attachment" "admin_user" {
  user       = aws_iam_user.admin_user.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

###############
# BASIC USER
###############
resource "aws_iam_user" "basic_user" {
  name          = "${var.project_name}-eksadmin2"
  path          = "/"
  force_destroy = true
  tags          = var.common_tags
}

resource "aws_iam_user_policy" "basic_user_eks_policy" {
  name = "${var.project_name}-eks-dashboard-full-access-policy"
  user = aws_iam_user.basic_user.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = [
        "iam:ListRoles",
        "eks:*",
        "ssm:GetParameter"
      ],
      Effect   = "Allow",
      Resource = "*"
    }]
  })
}

###############################
# EKSADMINS GROUP + USER
###############################
resource "aws_iam_group" "eksadmins_iam_group" {
  name = "${var.project_name}-eksadmins"
  path = "/"
}

resource "aws_iam_group_policy" "eksadmins_iam_group_assumerole_policy" {
  name  = "${var.project_name}-eksadmins-group-policy"
  group = aws_iam_group.eksadmins_iam_group.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action   = ["sts:AssumeRole"],
      Effect   = "Allow",
      Sid      = "AllowAssumeOrganizationAccountRole",
      Resource = var.eks_admin_role_arn
    }]
  })
}

resource "aws_iam_user" "eksadmin_user" {
  name          = "${var.project_name}-eksadmin3"
  path          = "/"
  force_destroy = true
  tags          = var.common_tags
}

resource "aws_iam_group_membership" "eksadmins" {
  name  = "${var.project_name}-eksadmins-group-membership"
  users = [aws_iam_user.eksadmin_user.name]
  group = aws_iam_group.eksadmins_iam_group.name
}

###############################
# EKSREADONLY GROUP + USER
###############################
resource "aws_iam_group" "eksreadonly_iam_group" {
  name = "${var.project_name}-eksreadonly"
  path = "/"
}

resource "aws_iam_group_policy" "eksreadonly_iam_group_assumerole_policy" {
  name  = "${var.project_name}-eksreadonly-group-policy"
  group = aws_iam_group.eksreadonly_iam_group.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action   = ["sts:AssumeRole"],
      Effect   = "Allow",
      Sid      = "AllowAssumeOrganizationAccountRole",
      Resource = var.eks_readonly_role_arn
    }]
  })
}

resource "aws_iam_user" "eksreadonly_user" {
  name          = "${var.project_name}-eksreadonly1"
  path          = "/"
  force_destroy = true
  tags          = var.common_tags
}

resource "aws_iam_group_membership" "eksreadonly" {
  name  = "${var.project_name}-eksreadonly-group-membership"
  users = [aws_iam_user.eksreadonly_user.name]
  group = aws_iam_group.eksreadonly_iam_group.name
}

###############################
# EKSDEVELOPER GROUP + USER
###############################
resource "aws_iam_group" "eksdeveloper_iam_group" {
  name = "${var.project_name}-eksdeveloper"
  path = "/"
}

resource "aws_iam_group_policy" "eksdeveloper_iam_group_assumerole_policy" {
  name  = "${var.project_name}-eksdeveloper-group-policy"
  group = aws_iam_group.eksdeveloper_iam_group.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action   = ["sts:AssumeRole"],
      Effect   = "Allow",
      Sid      = "AllowAssumeOrganizationAccountRole",
      Resource = var.eks_developer_role_arn
    }]
  })
}

resource "aws_iam_user" "eksdeveloper_user" {
  name          = "${var.project_name}-eksdeveloper1"
  path          = "/"
  force_destroy = true
  tags          = var.common_tags
}

resource "aws_iam_group_membership" "eksdeveloper" {
  name  = "${var.project_name}-eksdeveloper-group-membership"
  users = [aws_iam_user.eksdeveloper_user.name]
  group = aws_iam_group.eksdeveloper_iam_group.name
}
