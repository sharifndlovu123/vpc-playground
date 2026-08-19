output "tfstate_bucket_name" {
  value       = aws_s3_bucket.tfstate.bucket
  description = "Name of the S3 bucket holding Terraform remote state -- copy this into envs/*/backend.tf"
}
