# EKS Cluster Terraform Module

This Terraform module provisions an Amazon EKS cluster along with a VPC, subnets, and security groups. It is designed to be flexible and configurable, allowing you to customize the infrastructure to meet your needs.

## Features

- **VPC**: Creates a VPC with public and private subnets.
- **EKS Cluster**: Provisions an EKS cluster with configurable worker nodes.
- **Security Groups**: Allows for configurable security groups for the worker nodes.
- **Customizable**: Various properties such as instance types, EBS volume types, and more can be configured using variables.

## Usage

### 1. VPC Configuration

This module uses the `terraform-aws-modules/vpc/aws` module to create a VPC with public and private subnets.

```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name   = var.cluster_name
  cidr   = var.vpc_cidr
  azs    = local.azs

  private_subnets = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 48)]
  intra_subnets   = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 52)]

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = var.tags
}

```

### 2. EKS Cluster Configuration

This module provisions an EKS cluster using the `terraform-aws-modules/eks/aws` module.

```hcl
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = local.name
  cluster_version = "1.30"
  subnets         = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id

  tags = var.tags

  workers_group_defaults = {
    root_volume_type = var.root_volume_type
  }

  worker_groups = var.worker_groups
}

```

### 3. Security Groups Configuration

Security groups can be configured using the `security_groups` variable. Each security group can have custom ingress and egress rules.

```hcl
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

```

### 4. Variables

The following variables are available to customize the deployment:

| Variable | Description | Type | Default |
| --- | --- | --- | --- |
| `cluster_name` | The name of the EKS cluster. | `string` | `"my-eks-cluster"` |
| `vpc_cidr` | The CIDR block for the VPC. | `string` | `"10.0.0.0/16"` |
| `availability_zones` | List of availability zones to deploy resources in. | `list(string)` | `["us-west-2a"]` |
| `cluster_version` | The Kubernetes version for the EKS cluster. | `string` | `"1.30"` |
| `root_volume_type` | EBS volume type for the root volumes of worker nodes. | `string` | `"gp2"` |
| `node_groups` | List of node group configurations. | `list(object)` | See below for default |
| `security_groups` |	A map of security groups with their configurations.	| `map(object)`	|See below for default |
| `tags` | A map of tags to apply to resources. | `map(string)` | `{ Environment = "dev" }` |

### Default `node_groups` Configuration

```hcl
worker_groups = [
  {
    desired_capacity = 2
      max_capacity     = 3
      min_capacity     = 1

      instance_type = "t3.micro"
      key_name       = ""
  }
]

```
### Default security_groups Configuration
``` hcl
security_groups = {
  worker_sg = {
    description = "Security group for EKS worker nodes"
    ingress_rules = [
      {
        from_port   = 0
        to_port     = 65535
        protocol    = "tcp"
        cidr_blocks = ["10.0.0.0/16"]
      }
    ]
    egress_rules = [
      {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]
  }
}
```
### 5. Example

Here’s an example of how to use the module:

```hcl
module "eks_cluster" {
  source = "./path-to-your-module"

  cluster_name = "my-cluster"
  cidr         = "10.0.0.0/16"
  azs          = ["us-west-2a", "us-west-2b", "us-west-2c"]

  root_volume_type = "gp3"

  worker_groups = [
    {
      name                          = "worker-group-1"
      instance_type                 = "t2.small"
      asg_desired_capacity          = 2
      additional_security_group_ids = ["sg-0123456789abcdef0"]
    },
    {
      name                          = "worker-group-2"
      instance_type                 = "t2.medium"
      asg_desired_capacity          = 1
      additional_security_group_ids = ["sg-0123456789abcdef1"]
    }
  ]

  security_groups = [
    {
      name        = "custom-sg"
      description = "Custom security group"
      ingress = [
        {
          from_port   = 80
          to_port     = 80
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
      egress = [
        {
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
    }
  ]

  tags = {
    Environment = "production"
    Project     = "my-eks-cluster"
  }
}
```

### 6. Applying the Configuration

1. **Initialize Terraform:**
    
    ```bash
    terraform init
    ```
    
2. **Plan the Deployment:**
    
    ```bash
    terraform plan
    ```
    
3. **Apply the Configuration:**
    
    ```bash
    terraform apply
    ```
    

### 7. Outputs

This module will output the following:

| Output | Description |
| --- | --- |
| `eks_cluster_id` | The ID of the created EKS cluster. |
| `vpc_id` | The ID of the created VPC. |
| `worker_group_ids` | The IDs of the worker node groups. |