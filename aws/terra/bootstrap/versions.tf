# bootstrap/ has NO backend "s3" block on purpose -- it's what CREATES the
# bucket that every other config's backend points at. It stays on local
# state permanently and is applied rarely (once, then only if the bucket
# itself needs to change).
terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.60.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}
