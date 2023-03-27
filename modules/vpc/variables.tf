variable "vpc_cidr_block" {
  description = "CIDR of the VPC"
  type = string
}

variable "vpc_name" {
  description = "VPC name (tag)"
  type = string
}

// This is the input variable that 'vpc' module will iterate over to create a set of private subnets
variable "private_subnets" {
  description = "Configuration parameters for private subnets"
  type = list(object({
    zone = string
    cidr_block = string
    name = string
  }))
}
