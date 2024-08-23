output "eks_cluster_name" {
  value = module.aws_eks_cluster.name
}

output "eks_cluster_endpoint" {
  value = module.aws_eks_cluster.endpoint
}

output "eks_cluster_certificate_authority_data" {
  value = module.aws_eks_cluster.certificate_authority.0.data
}

output "eks_cluster_id" {
  value = module.aws_eks_cluster.id
}
