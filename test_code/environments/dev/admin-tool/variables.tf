# ============================================================
# Core Variables
# ============================================================
variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, prod, staging)"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "created_by" {
  description = "Who created the infra"
  type        = string
}

# ============================================================
# VPC Configuration
# ============================================================
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "enable_nat_gateway" {
  description = "Whether to enable NAT Gateway"
  type        = bool
}

variable "single_nat_gateway" {
  description = "Whether to use a single NAT Gateway"
  type        = bool
}

variable "create_database_subnets" {
  description = "Whether to create DB subnets"
  type        = bool
}

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs"
  type        = bool
}

variable "flow_log_retention_days" {
  description = "Retention days for Flow Logs"
  type        = number
}

variable "create_private_zone" {
  description = "Create a private Route53 hosted zone"
  type        = bool
}

variable "domain_name" {
  description = "Domain name for Route53 zone"
  type        = string
}

# ============================================================
# Backend Configuration
# ============================================================
variable "tf_state_bucket" {
  description = "S3 bucket for Terraform state"
  type        = string
}

variable "tf_state_lock_table" {
  description = "DynamoDB table for state locking"
  type        = string
}
