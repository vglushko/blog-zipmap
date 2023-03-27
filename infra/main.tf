// We start by setting required providers and their exact versions
// to protect ourselves from any possible changes in the provider code.
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.60.0"
    }
  }
}

// Then we configure our AWs provider with the profile name and region
// as well as the default tags that will be applied to any resource created.
provider "aws" {
  profile = "default"
  region = "eu-west-1"
  default_tags {
    tags = {
      Type = "poc"
      Terraform = true
    }
  }
}

// Now, let's create a VPC.
module "vpc" {
  source = "../modules/vpc"

  // We set name and CIDR block for our VPC.
  vpc_name = "poc-vpc"
  vpc_cidr_block = "172.16.0.0/16"

  // Now we configure 3 private subnets.
  private_subnets = [{
    name = "private-zone-a"
    cidr_block = "172.16.0.0/23"
    zone = "eu-west-1a"
  }, {
    name = "private-zone-b"
    cidr_block = "172.16.2.0/23"
    zone = "eu-west-1b"
  }, {
    name = "private-zone-c"
    cidr_block = "172.16.4.0/23"
    zone = "eu-west-1c"
  }]
}

// Now let's place a lambda function to the private subnets in our VPC.
// This is the example of another resource referencing our new private subnets.
resource "aws_lambda_function" "this" {
  function_name = "poc-test"

  vpc_config {
    // Now we can reference the particular instances of private subnets by their names.
    // This improves the maintainability of the code and makes it less sensitive to the configuration changes.
    subnet_ids = [module.vpc.private_subnet_ids["private-zone-a"], module.vpc.private_subnet_ids["private-zone-c"]]
    security_group_ids = [aws_security_group.this.id]
  }

  // The following parameters are needed to deploy a minimum possible lambda function
  role = aws_iam_role.this.arn
  filename = "./index.zip"
  handler = "index.handler"
  runtime = "nodejs18.x"
}

// This role is what lambda function needs on creation.
resource "aws_iam_role" "this" {
  name = "poc-iam-role-for-lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid = "LambdaAssumedRole"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "this" {
  role = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_security_group" "this" {
  name = "poc-security-group-for-lambda"
  vpc_id = module.vpc.vpc_id
}