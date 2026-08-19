# The backend "s3" block lives in backend.tf, not here, because its bucket
# name has to be a literal string filled in by hand after `terraform apply`
# in bootstrap/ -- keeping it separate means `terraform init` works on local
# state until you're ready to migrate.
terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.60.0"
    }
  }
}
