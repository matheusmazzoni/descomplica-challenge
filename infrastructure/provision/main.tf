terraform {
  required_version = ">= 1.0.9"

  backend "s3" {
    bucket         = "sltools-terraform-state"
    key            = "states/terraform.tfstate"
    region         = "us-west-1"
    dynamodb_table = "sltools-terraform-locks"
    encrypt        = true
  }
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.6"
    }
  }
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "descomplica-mazzoni-terraform-state"
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "versioning_terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_acl" "this" {
  bucket = aws_s3_bucket.terraform_state.id
  acl    = "private"
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "sltools-terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}

locals {
  env_prefix   = var.environment == "production" ? "prd" : (var.environment == "staging" ? "stg": "dev")
  vpc_name     = "${local.env_prefix}-${var.vpc_name}"
  cluster_name = "${local.env_prefix}-${var.cluster_name}"
  common_tags  = {
    Environment = var.environment
  }
}


#### Key Pair ####
resource "tls_private_key" "infra" {
  algorithm = "RSA"
}

resource "aws_key_pair" "infra" {
  key_name   = "infra-key"
  public_key = tls_private_key.infra.public_key_openssh

  depends_on = [
    tls_private_key.infra
  ]
}

resource "local_file" "infra_key" {
  sensitive_content  = aws_key_pair.infra.public_key
  filename = "infra-key.pub"
}


#### Network ####
module "network" {
  source = "terraform-aws-modules/vpc/aws"
  version = "3.11.5"

  name = local.vpc_name
  cidr = var.vpc_cidr
  azs  = ["${data.aws_region.current.name}a", "${data.aws_region.current.name}b", "${data.aws_region.current.name}c"]
  
  public_subnets       = var.public_subnets
  public_subnet_suffix = "public"
  public_subnet_tags   = { Access = "Public" }

  private_subnets       = var.private_subnets
  private_subnet_suffix = "private"
  private_subnet_tags   = { Access = "Private" }

  enable_nat_gateway = true
  single_nat_gateway = true
  one_nat_gateway_per_az = false

  tags = merge(local.common_tags, {
    Purpose = "network"
  })
}


### EKS ###
module "eks" {
  source = "terraform-aws-modules/eks/aws"
  version = "18.7.2"

  cluster_name                    = local.cluster_name
  cluster_version                 = var.cluster_version
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
  }

  vpc_id     = module.network.vpc_id
  subnet_ids = module.network.private_subnets

  create_iam_role              = true
  iam_role_name                = "${local.cluster_name}-role"
  iam_role_use_name_prefix     = false
  iam_role_description         = "EKS Cluster role"

  eks_managed_node_group_defaults = {
    ami_type               = "AL2_x86_64"
    disk_size              = 50
    instance_types         = ["t3.large"]
  }

  eks_managed_node_groups = {
    default_ng = {
      name            = "${local.cluster_name}-ng"
      use_name_prefix = true
      subnet_ids      = module.network.private_subnets

      min_size       = 1
      max_size       = 5
      desired_size   = 1
      capacity_type  = "SPOT"

      create_iam_role              = true
      iam_role_name                = "${local.cluster_name}-ng-role"
      iam_role_use_name_prefix     = false
      iam_role_description         = "EKS node group role"
    }
  }

  node_security_group_additional_rules = {
    ingress_nodes_ports = {
      description      = "Node to node all ports/protocols"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "ingress"
      cidr_blocks      = module.network.private_subnets_cidr_blocks
    }
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }
  
  tags = merge(local.common_tags, {
    Purpose = "Cluster"
  })
}

