resource "aws_eks_node_group" "eks_ng_private" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  node_role_arn = var.node_role_arn
  subnet_ids    = var.private_subnets

  scaling_config {
    desired_size = 1
    min_size     = 1
    max_size     = 2
  }

  instance_types = ["t3.medium"]
  disk_size      = 20
}
