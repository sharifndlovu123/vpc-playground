# Backend blocks can't reference resources/variables -- bucket name below is
# the literal `tfstate_bucket_name` output from bootstrap/, and `profile`
# has to be spelled out too: this block has its own independent credential
# chain, completely separate from the `provider "aws"` block in providers.tf.
# Without an explicit profile here, it falls back to env vars / the
# [default] CLI profile instead of the one you actually intend.
#
# Terraform 1.15.8 supports native S3 locking, so no DynamoDB table is
# needed -- use_lockfile writes a ".tflock" companion object next to the
# state object and uses a conditional-write to S3 as the lock.
terraform {
  backend "s3" {
    bucket       = "your-own-bucket-name" # replace with your actual bucket name
    key          = "envs/prod/terraform.tfstate"
    region       = "af-south-1"
    profile      = "your-aws-profile" # replace with your actual AWS CLI profile
    use_lockfile = true
    encrypt      = true
  }
}
