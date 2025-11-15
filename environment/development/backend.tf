terraform {
  backend "s3" {
    bucket         = "terraform-on-aws-eks2025110431290"
    key            = "dev/eks-cluster/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "dev-efs-eks202511043"
    encrypt        = true
  }
}
