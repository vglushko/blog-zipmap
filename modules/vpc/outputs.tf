output "private_subnet_ids" {
  description = "Private subnets"
  value = zipmap(aws_subnet.private[*].tags["Name"], aws_subnet.private[*].id)
  // Alternatively, we could also reference to the input variable instead of the resource property
  // as it is shown in the commented code below 
  // value = zipmap(var.private_subnets[*].name, aws_subnet.private[*].id) 
}

output "vpc_id" {
  description = "VPC id"
  value = aws_vpc.vpc.id
}
