# ============================================================
# VPC Outputs
# ============================================================
output "vpc_id" {
  description = "ID of the VPC"
  value       = {
    environment = var.environment
    project     = var.project_name
    id          = aws_vpc.main.id
  }
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value = {
    environment = var.environment
    cidr_block  = aws_vpc.main.cidr_block
  }
}

output "availability_zones" {
  description = "List of availability zones used"
  value = {
    environment = var.environment
    azs         = local.azs
  }
}

# ============================================================
# Internet Gateway
# ============================================================
output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value = {
    environment = var.environment
    id          = aws_internet_gateway.main.id
  }
}

# ============================================================
# Subnets
# ============================================================
output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value = {
    environment = var.environment
    ids         = aws_subnet.public[*].id
  }
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value = {
    environment = var.environment
    ids         = aws_subnet.private[*].id
  }
}

output "database_subnet_ids" {
  description = "IDs of the database subnets (if created)"
  value = {
    environment = var.environment
    ids         = var.create_database_subnets ? aws_subnet.database[*].id : []
  }
}

# ============================================================
# NAT Gateways
# ============================================================
output "nat_gateway_ids" {
  description = "IDs of the NAT Gateways (if created)"
  value = {
    environment = var.environment
    ids         = var.enable_nat_gateway ? aws_nat_gateway.main[*].id : []
  }
}

output "nat_gateway_public_ips" {
  description = "Public IPs of the NAT Gateways (if created)"
  value = {
    environment = var.environment
    ips         = var.enable_nat_gateway ? aws_eip.nat[*].public_ip : []
  }
}

# ============================================================
# Security Groups
# ============================================================
output "security_group_ids" {
  description = "Security group IDs"
  value = {
    environment = var.environment
    alb         = aws_security_group.alb.id
    ecs_tasks   = aws_security_group.ecs_tasks.id
  }
}

# ============================================================
# Route53 (Optional)
# ============================================================
output "route53_zone_id" {
  description = "Route53 private hosted zone ID (if created)"
  value = {
    environment = var.environment
    zone_id     = var.create_private_zone ? aws_route53_zone.private[0].zone_id : null
  }
}

# ============================================================
# Flow Logs (Optional)
# ============================================================
output "flow_log_group_arn" {
  description = "ARN of CloudWatch Log Group for VPC Flow Logs (if enabled)"
  value = {
    environment = var.environment
    arn         = var.enable_flow_logs ? aws_cloudwatch_log_group.flow_logs[0].arn : null
  }
}

# ============================================================
# Subnet Details (Useful for debugging)
# ============================================================
output "subnet_details" {
  description = "Detailed subnet information"
  value = {
    environment = var.environment
    public = {
      for subnet in aws_subnet.public :
      subnet.availability_zone => {
        id         = subnet.id
        cidr_block = subnet.cidr_block
        az         = subnet.availability_zone
      }
    }
    private = {
      for subnet in aws_subnet.private :
      subnet.availability_zone => {
        id         = subnet.id
        cidr_block = subnet.cidr_block
        az         = subnet.availability_zone
      }
    }
    database = var.create_database_subnets ? {
      for subnet in aws_subnet.database :
      subnet.availability_zone => {
        id         = subnet.id
        cidr_block = subnet.cidr_block
        az         = subnet.availability_zone
      }
    } : {}
  }
}
