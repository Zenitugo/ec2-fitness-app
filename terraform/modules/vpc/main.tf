################ ###########  Create VPC  #############################
resource "aws_vpc"  "vpc" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.environment_name}-vpc"
  }
}


###############################  Create Internet Gateway  #############################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id 
    tags = {
        Name = "${var.environment_name}-igw"
    }  
}