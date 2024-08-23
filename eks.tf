module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = var.cluster_name
  cluster_version = "1.30"
  subnets         = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id


  tags = var.tags

  workers_group_defaults = {
    root_volume_type = var.root_volume_type
  }

  worker_groups = var.worker_groups

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