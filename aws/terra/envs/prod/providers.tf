# default_tags applies to every resource this provider creates (merged with
# any tags set on the resource itself) -- without a CloudFormation stack to
# group things, this is what makes a Terraform-managed resource findable and
# attributable when you're looking at the AWS console/CLI directly.
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile

  default_tags {
    tags = {
      ManagedBy   = "terraform"
      Project     = "vpc-learning"
      Environment = "prod"
    }
  }
}
