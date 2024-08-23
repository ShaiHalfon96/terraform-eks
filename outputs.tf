output "eks_cluster_name" {
  value = aws_eks_cluster.name
}

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.endpoint
}

output "eks_cluster_certificate_authority_data" {
  value = aws_eks_cluster.certificate_authority.0.data
}

output "eks_cluster_id" {
  value = aws_eks_cluster.id
}
