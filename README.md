# AWS Infrastructure

Terraform configuration for the AWS environment in `us-west-1`.

## Layout

| Path | Purpose |
|------|---------|
| `main.tf` | Provider, Terraform Cloud workspace, account password policy, and module wiring |
| `modules/vpc` | VPC and security groups |
| `modules/subnet` | Primary and secondary subnets |
| `modules/storage` | PostgreSQL RDS instance, KMS key, SSM parameters, and S3 buckets |
| `modules/iam` | Environment IAM role |
| EC2 instance | `terraform-aws-modules/ec2-instance/aws` registry module |

## Usage

Set `access_key` and `secret_key` in `credentials.auto.tfvars`, then:

```
terraform init
terraform plan -out tfplan.binary
terraform show -json tfplan.binary > tf-plan.json
terraform apply tfplan.binary
```

The environment defaults to `dev` (`var.env`).
