# backend.tf
# ------------------------------------------------------------------------------
# This file configures Terraform to use a remote backend (S3 + DynamoDB) 
# for storing and locking the Terraform state file.
# 
# Why? 
# - State contains all resource mappings (VPC IDs, subnet IDs, etc.)
# - Keeping it in S3 makes it shareable across team members
# - DynamoDB ensures only one person modifies state at a time (locking)
# ------------------------------------------------------------------------------


/*
terraform {
  backend "s3" {
    bucket          = "aacs-intertrust-tf-state-files"
    key             = "dev/terraform.tfstate"
    region          = "us-west-2"
    dynamodb_table  = "terraform-state-lock"
    encrypt         = true
  }
}


terraform {
  backend "s3" {
    bucket         = var.tf_state_bucket
    key            = "${var.project_name}/${var.environment}/terraform.tfstate"
    region         = var.aws_region
    dynamodb_table = var.tf_state_lock_table
    encrypt        = true
  }
}

*/

# LOCAL

terraform {
  backend "local" {
    path = "./terraform.tfstate"
  }
}




# terraform {
#   backend "s3" {
#     bucket         = "aacs-intertrust-tf-state-files"   # S3 bucket name
#     key            = "dev/admin-tool/terraform.tfstate" # Path inside bucket
#     region         = "us-west-2"
#     dynamodb_table = "terraform-state-lock"             # DynamoDB for state locking
#     encrypt        = true
#   }
# }





/*
backend variables (var.tf_state_bucket, etc.) cannot be set from variables.tf / tfvars directly. Terraform requires them passed either via -backend-config or hardcoded.
That means when you run terraform init, you must do:

terraform init \
  -backend-config="bucket=aacs-intertrust-tf-state-files" \
  -backend-config="key=dev/terraform.tfstate" \
  -backend-config="region=us-west-2" \
  -backend-config="dynamodb_table=terraform-state-lock"

*/