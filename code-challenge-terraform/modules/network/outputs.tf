output "id" {
  value = aws_vpc.vpc.id
}

output "public_subnet_ids" {
  value = module.public_subnets.subnet_id
}

output "private_subnet_ids" {
  value = module.private_subnets.subnet_id
}