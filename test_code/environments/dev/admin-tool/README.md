```markdown
# Admin Tool Infrastructure

This directory contains Terraform configurations to provision infrastructure for the **Admin Tool** project.  
The setup is designed to manage multiple environments (`dev`, `prod`) consistently using reusable modules.

---

## Directory Layout

```

admin-tool/
├── backend.tf             # Remote state backend (S3 + DynamoDB)
├── main.tf                # Root module configuration (calls VPC module)
├── provider.tf            # AWS provider + default tags
├── variables.tf           # Variable definitions
├── terraform.dev.tfvars   # Variables for dev environment
├── terraform.prod.tfvars  # Variables for prod environment

````

---

## Remote State

Terraform state is stored remotely in:

- **S3 bucket:** `aacs-intertrust-tf-state-files`
- **DynamoDB table (locking):** `terraform-state-lock`
- **Region:** `us-west-2`

This ensures safe collaboration and state consistency.

---

## Usage

### 1. Initialize

Run this once per environment to configure the backend and download providers:

```bash
terraform init
````

---

### 2. Plan & Apply

#### Dev Environment

```bash
terraform plan -var-file=terraform.dev.tfvars -out=tfplan
terraform apply tfplan
```

#### Prod Environment

```bash
terraform plan -var-file=terraform.prod.tfvars -out=tfplan
terraform apply tfplan
```

---

### 3. Destroy (if needed)

```bash
terraform destroy -var-file=terraform.dev.tfvars
terraform destroy -var-file=terraform.prod.tfvars
```

---

## Outputs

After `apply`, Terraform will display useful outputs such as:

* `vpc_id`
* `subnet_ids` (public, private, database)
* `nat_gateway_ids`
* `route53_zone_id`
* `security_group_ids`

You can also run:

```bash
terraform output
```

---

## Notes

* **Never hardcode secrets or credentials** in tfvars or tf files. Use AWS IAM roles or SSM Parameter Store instead.
* The `backend.tf` file currently points to the **dev state file** (`dev/terraform.tfstate`).
  If you want separate state files for `prod`, you may need to update the `key` value or use workspaces.
* Costs: NAT Gateways, RDS, and VPC Flow Logs incur AWS costs.
  Use `single_nat_gateway = true` in non-prod environments for cost optimization.

---
