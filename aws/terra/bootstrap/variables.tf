variable "aws_region" {
  description = "AWS region to create the Terraform state bucket in"
  type        = string
  default     = "af-south-1"
}

variable "aws_profile" {
  description = "AWS CLI profile to authenticate with"
  type        = string
  default     = "your-own-aws-profile" # replace with your actual AWS CLI profile
}
