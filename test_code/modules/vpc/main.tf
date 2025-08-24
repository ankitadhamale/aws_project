# ============================================================
# VPC
# ============================================================
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-vpc"
    Environment = var.environment
  }
}

# ============================================================
# Subnets (Public, Private, Database)
# ============================================================
data "aws_availability_zones" "available" {}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 2) # use 2 AZs
}

resource "aws_subnet" "public" {
  count                   = length(local.azs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 4, count.index)
  map_public_ip_on_launch = true
  availability_zone       = local.azs[count.index]

  tags = {
    Name = "${var.project_name}-${var.environment}-public-${local.azs[count.index]}"
  }
}

resource "aws_subnet" "private" {
  count             = length(local.azs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, count.index + 10)
  availability_zone = local.azs[count.index]

  tags = {
    Name = "${var.project_name}-${var.environment}-private-${local.azs[count.index]}"
  }
}

resource "aws_subnet" "database" {
  count             = var.create_database_subnets ? length(local.azs) : 0
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, count.index + 20)
  availability_zone = local.azs[count.index]

  tags = {
    Name = "${var.project_name}-${var.environment}-db-${local.azs[count.index]}"
  }
}

# ============================================================
# Internet Gateway
# ============================================================
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-${var.environment}-igw"
  }
}

# ============================================================
# NAT Gateway
# ============================================================
resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(local.azs)) : 0
  domain = "vpc"
}

resource "aws_nat_gateway" "main" {
  count         = length(aws_eip.nat)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index % length(aws_subnet.public)].id

  tags = {
    Name = "${var.project_name}-${var.environment}-nat-${count.index}"
  }
}

# ============================================================
# Route Tables
# ============================================================
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  count = length(aws_nat_gateway.main)

  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-private-rt-${count.index}"
  }
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = element(aws_route_table.private[*].id, count.index % length(aws_route_table.private))
}

# ============================================================
# Security Groups
# ============================================================
resource "aws_security_group" "alb" {
  name        = "${var.project_name}-${var.environment}-alb-sg"
  vpc_id      = aws_vpc.main.id
  description = "Allow HTTP/HTTPS for ALB"
}

resource "aws_security_group" "ecs_tasks" {
  name        = "${var.project_name}-${var.environment}-ecs-sg"
  vpc_id      = aws_vpc.main.id
  description = "Allow ECS tasks to communicate"
}

# ============================================================
# Route53 Private Hosted Zone (optional)
# ============================================================
resource "aws_route53_zone" "private" {
  count = var.create_private_zone ? 1 : 0
  name  = "${var.domain_name}.internal"
  vpc {
    vpc_id = aws_vpc.main.id
  }
}

# ============================================================
# VPC Flow Logs (optional)
# ============================================================
resource "aws_cloudwatch_log_group" "flow_logs" {
  count             = var.enable_flow_logs ? 1 : 0
  name              = "/aws/vpc/${var.project_name}-${var.environment}-flowlogs"
  retention_in_days = var.flow_log_retention_days
}

resource "aws_flow_log" "vpc" {
  count           = var.enable_flow_logs ? 1 : 0
  log_destination = aws_cloudwatch_log_group.flow_logs[0].arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.main.id
}
