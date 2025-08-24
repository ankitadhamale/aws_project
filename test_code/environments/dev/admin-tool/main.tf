# ============================================================
# VPC Module
# ============================================================
module "vpc" {
  source = "../../../modules/vpc"

  aws_region              = var.aws_region
  environment             = var.environment
  project_name            = var.project_name
  created_by              = var.created_by
  vpc_cidr                = var.vpc_cidr
  enable_nat_gateway      = var.enable_nat_gateway
  single_nat_gateway      = var.single_nat_gateway
  create_database_subnets = var.create_database_subnets
  enable_flow_logs        = var.enable_flow_logs
  flow_log_retention_days = var.flow_log_retention_days
#   create_private_zone     = var.create_private_zone
#   domain_name             = var.domain_name
}
