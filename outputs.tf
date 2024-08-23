output "eks_cluster_name" {
  value = module.aws_eks_cluster.cluster_name
}

output "eks_cluster_endpoint" {
  value = module.aws_eks_cluster.cluster_endpoint
}

output "eks_cluster_id" {
  value = module.aws_eks_cluster.cluster_id
}
