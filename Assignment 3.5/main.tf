terraform {
  backend "s3" {
    bucket         = "christanyks3.tfstate-backend.com"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  prefix = "christanyk"
  common_tags = {
    Terraform = "true"
  }
}

# --- Network Module ---
module "network" {
  source               = "./modules/network"
  prefix               = local.prefix
  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  availability_zones   = slice(data.aws_availability_zones.available.names, 0, 2)
  tags                 = local.common_tags
}

# --- ECR Module ---
module "ecr" {
  source           = "./modules/ecr"
  repository_name  = "${local.prefix}-flask-app"
  tags             = local.common_tags
}

# --- IAM Module ---
module "iam" {
  source           = "./modules/iam"
  prefix           = local.prefix
  s3_bucket_arn    = "arn:aws:s3:::christanyks3.tfstate-backend.com"
  dynamodb_table   = "terraform-state-locks"
  tags             = local.common_tags
}

# --- ECS Module ---
module "ecs" {
  source              = "./modules/ecs"
  prefix              = local.prefix
  vpc_id              = module.network.vpc_id
  public_subnet_ids   = module.network.public_subnet_ids
  ecr_repository_url  = module.ecr.repository_url
  container_port      = 8080
  ecs_execution_role_arn = module.iam.ecs_execution_role_arn
  tags                = local.common_tags

  depends_on = [module.ecr]
}

# --- Outputs ---
output "vpc_id" {
  value = module.network.vpc_id
}

output "ecr_repository_url" {
  value = module.ecr.repository_url
}

output "ecs_cluster_name" {
  value = module.ecs.cluster_name
}

output "ecs_service_name" {
  value = module.ecs.service_name
}

output "ecs_exec_role_arn" {
  value = module.iam.ecs_execution_role_arn
}
