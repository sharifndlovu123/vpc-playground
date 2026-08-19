variable "aws_region" {
  description = "AWS region to deploy the VPC into"
  type        = string
  default     = "af-south-1"
}

variable "aws_profile" {
  description = "AWS CLI profile to authenticate with"
  type        = string
  default     = "your-aws-profile" # replace with your actual AWS CLI profile
}
