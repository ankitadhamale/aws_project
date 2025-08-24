# ============================================================
# General Variables
# ============================================================

variable "aws_region" {
  description = "AWS region where resources will be deployed"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "created_by" {
  description = "Tag to identify who created the resources"
  type        = string
  default     = "terraform"
}

# ============================================================
# VPC Configuration
# ============================================================

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of AZs to use (defaults to all in region)"
  type        = list(string)
  default     = []
}

# ============================================================
# NAT Gateway
# ============================================================

variable "enable_nat_gateway" {
  description = "Whether to create NAT gateways for private subnets"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Whether to use a single NAT gateway (cost optimization)"
  type        = bool
  default     = false
}

# ============================================================
# Subnets
# ============================================================

variable "create_database_subnets" {
  description = "Whether to create database subnets"
  type        = bool
  default     = false
}

# ============================================================
# VPC Flow Logs
# ============================================================

variable "enable_flow_logs" {
  description = "Whether to enable VPC Flow Logs"
  type        = bool
  default     = true
}

variable "flow_log_retention_days" {
  description = "Number of days to retain VPC flow logs"
  type        = number
  default     = 14
}

# ============================================================
# Route53 Private Zone
# ============================================================

variable "create_private_zone" {
  description = "Whether to create a private Route 53 hosted zone"
  type        = bool
  default     = false
}

variable "domain_name" {
  description = "Domain name for the private hosted zone (if created)"
  type        = string
  default     = null
}
