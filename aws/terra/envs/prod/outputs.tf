# example of sensitive output
output "vpc_id" {
  value       = aws_vpc.my_vpc.id
  sensitive   = true
  description = "The ID of the VPC created"
}

output "public_subnet_id" {
  value       = aws_subnet.public.id
  sensitive   = true
  description = "The ID of the public subnet created"
}

output "private_subnet_id" {
  value       = aws_subnet.private.id
  sensitive   = true
  description = "The ID of the private subnet created"
}

output "internet_gateway_id" {
  value       = aws_internet_gateway.gw.id
  sensitive   = true
  description = "The ID of the internet gateway created"
}

output "route_table_id" {
  value       = aws_vpc.my_vpc.default_route_table_id
  sensitive   = true
  description = "The ID of the route table created"
}
