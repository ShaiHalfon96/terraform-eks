module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "~> 20.0"
  cluster_name    = var.cluster_name
  cluster_version = "1.30"
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets

  tags = var.tags

  eks_managed_node_groups = {
    default = var.node_groups
  }
}

resource "aws_security_group" "worker_group" {
  count       = length(var.security_groups)
  name        = var.security_groups[count.index].name
  description = var.security_groups[count.index].description
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = each.value.ingress[0].from_port
    to_port     = each.value.ingress[0].to_port
    protocol    = each.value.ingress[0].protocol
    cidr_blocks = each.value.ingress[0].cidr_blocks
  }

  egress {
    from_port   = each.value.egress[0].from_port
    to_port     = each.value.egress[0].to_port
    protocol    = each.value.egress[0].protocol
    cidr_blocks = each.value.egress[0].cidr_blocks
  }

  tags = var.tags
}