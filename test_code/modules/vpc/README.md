````markdown
# VPC Module

This Terraform module creates a production-ready **VPC network foundation** for AWS, following best practices and Zero Trust–ready (vKGF) principles.

---

## Features

- VPC with configurable CIDR
- Public, private, and optional database subnets (spread across AZs)
- Internet Gateway for public subnets
- NAT Gateways (single or per-AZ)
- Route tables and associations
- Security groups for ALB and ECS tasks
- Optional VPC Flow Logs (CloudWatch)
- Outputs for easy integration with other modules

---

## Usage

```hcl
module "vpc" {
  source = "../modules/vpc"

  aws_region             = "us-west-2"
  environment            = "dev"
  project_name           = "myapp"
  vpc_cidr               = "10.0.0.0/16"
  enable_nat_gateway     = true
  single_nat_gateway     = false
  create_database_subnets = true
  enable_flow_logs       = true
  flow_log_retention_days = 14
}
````

---

## Inputs

| Name                       | Description                                            | Type   | Default     | Required |
| -------------------------- | ------------------------------------------------------ | ------ | ----------- | -------- |
| aws\_region                | AWS region                                             | string | us-west-2   | no       |
| environment                | Environment name (e.g., dev, prod)                     | string | dev         | no       |
| project\_name              | Name of the project                                    | string | myapp       | no       |
| created\_by                | Tag for resource ownership                             | string | terraform   | no       |
| vpc\_cidr                  | CIDR block for the VPC                                 | string | 10.0.0.0/16 | no       |
| enable\_nat\_gateway       | Create NAT Gateways for private subnets                | bool   | true        | no       |
| single\_nat\_gateway       | Use a single NAT Gateway instead of one per AZ         | bool   | false       | no       |
| create\_database\_subnets  | Whether to create isolated database subnets            | bool   | false       | no       |
| enable\_flow\_logs         | Enable VPC Flow Logs                                   | bool   | true        | no       |
| flow\_log\_retention\_days | Retention period for flow logs (CloudWatch)            | number | 14          | no       |
| create\_private\_zone      | Whether to create a private Route 53 zone (future use) | bool   | true        | no       |
| domain\_name               | Domain name for private hosted zone                    | string | company     | no       |

---

## Outputs

| Name                      | Description                          |
| ------------------------- | ------------------------------------ |
| vpc\_id                   | ID of the VPC                        |
| vpc\_cidr\_block          | CIDR block of the VPC                |
| availability\_zones       | List of AZs used                     |
| internet\_gateway\_id     | Internet Gateway ID                  |
| public\_subnet\_ids       | IDs of public subnets                |
| private\_subnet\_ids      | IDs of private subnets               |
| database\_subnet\_ids     | IDs of database subnets (if created) |
| nat\_gateway\_ids         | NAT Gateway IDs (if created)         |
| nat\_gateway\_public\_ips | NAT Gateway public IPs (if created)  |
| security\_group\_ids      | Security group IDs (ALB, ECS tasks)  |
| subnet\_details           | Map of subnet details by type and AZ |

---

## Notes

* **Database subnets** are isolated (no internet access). Use RDS or similar managed services inside.
* **NAT Gateways** add cost. For dev/test environments, you may prefer `single_nat_gateway = true`.
* **Flow Logs** default to CloudWatch. S3 delivery can be added if compliance requires.
* Module is designed to be extended with **VPC Endpoints** and **VPC Lattice** for Zero Trust service-to-service communication.

---

## Example Integration

```hcl
module "ecs" {
  source           = "../modules/ecs"
  vpc_id           = module.vpc.vpc_id
  private_subnets  = module.vpc.private_subnet_ids
  security_groups  = [module.vpc.security_group_ids.ecs_tasks]
}
```

---
