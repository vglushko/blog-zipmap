// Create a VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    "Name" = var.vpc_name
  }
}

// Create private subnets by iterating over the subnet configuration parameters in the var.private_subnets variable
resource "aws_subnet" "private" {
  count = length(var.private_subnets)

  vpc_id = aws_vpc.vpc.id

  // Let's apply the configuration from our input variable.
  cidr_block = element(var.private_subnets, count.index).cidr_block
  availability_zone = element(var.private_subnets, count.index).zone
  tags = {
    "Name" = element(var.private_subnets[*].name, count.index)
  }
}
