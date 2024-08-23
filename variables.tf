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

variable "availability_zones" {
  description = "List of availability zones to deploy resources in"
  type        = list(string)
  default     = ["us-east-1a"]
}

variable "tags" {
  description = "Tags to be applied to resources"
  type        = map(string)
  default     = {
    Environment = "dev"
  }
}

variable "cluster_version" {
  description = "The Kubernetes version for the EKS cluster."
  type        = string
  default     = "1.30"
}

variable "root_volume_type" {
  description = "The EBS volume type for root volumes on worker nodes."
  type        = string
  default     = "gp2"
}

variable "node_groups" {
  description = "Configuration for node groups in the EKS cluster."
  type        = object({
    desired_size              = number
    max_size                  = number
    min_size                  = number
    instance_types            = list(string)
  })
  default = {
      desired_size                  = 2
      max_size                      = 3
      min_size                      = 1
      instance_types                = ["t3.micro"]
    }
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
          cidr_blocks = ["10.0.0.0/16"]
        }
      ]
      egress = [
        {
          from_port   = 0
          to_port     = 65535
          protocol    = "-1" # all protocols are allowed.
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
