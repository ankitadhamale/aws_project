variable "bucket_name" {
  description = "The name of the S3 bucket."
  type        = string
}

variable "region" {
  description = "The AWS region for the bucket."
  type        = string
  default     = "us-west-2"
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table for Terraform state locking"
  type        = string
}

variable "enable_point_in_time_recovery" {
  description = "Enable point-in-time recovery for DynamoDB table"
  type        = bool
}

variable "state_file_retention_days" {
  description = "Number of days to retain old state file versions"
  type        = Number
}
