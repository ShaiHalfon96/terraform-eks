variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "my-eks-cluster"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC subnets"
  type        = string
  default     = "10.0.0.0/16"
}

variable "tags" {
  description = "Tags to be applied to resources"
  type        = map(string)
  default     = {
    Environment = "dev"
  }
}

variable "root_volume_type" {
  description = "The EBS volume type for root volumes on worker nodes."
  type        = string
  default     = "gp2"
}

variable "worker_groups" {
  description = "Configuration for worker groups in the EKS cluster."
  type        = list(object({
    name                          = string
    instance_type                 = string
    asg_desired_capacity          = number
    additional_security_group_ids = list(string)
  }))
  default = [
    {
      name                          = "worker-group-1"
      instance_type                 = "t2.small"
      asg_desired_capacity          = 2
      additional_security_group_ids = []
    },
    {
      name                          = "worker-group-2"
      instance_type                 = "t2.small"
      asg_desired_capacity          = 1
      additional_security_group_ids = []
    },
  ]
}

variable "security_groups" {
  description = "List of security groups with their ingress and egress rules."
  type = list(object({
    name        = string
    description = string
    ingress = list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
    }))
    egress = list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
    }))
  }))
  default = [
    {
      name        = "worker-group-mgmt-one"
      description = "Security group for worker group 1"
      ingress = [
        {
          from_port   = 0
          to_port     = 65535
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
      egress = [
        {
          from_port   = 0
          to_port     = 65535
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
    },
    {
      name        = "worker-group-mgmt-two"
      description = "Security group for worker group 2"
      ingress = [
        {
          from_port   = 0
          to_port     = 65535
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
      egress = [
        {
          from_port   = 0
          to_port     = 65535
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
    },
  ]
}
