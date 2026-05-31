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


################################  Create Public Subnets  #############################
resource "aws_subnet" "public_subnet_1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(var.cidr_block, 8, 1)
  availability_zone = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.environment_name}-public-subnet-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(var.cidr_block, 8, 2)
  availability_zone = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.environment_name}-public-subnet-2"
  }
}



##############################  Create Private Subnets  #############################
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(var.cidr_block, 8, 3)
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "${var.environment_name}-private-subnet-1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(var.cidr_block, 8, 4)
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "${var.environment_name}-private-subnet-2"
  }
}



######################### Create Elastic IP  #############################
resource "aws_eip" "nat_eip_1" {
  vpc = true

  tags = {
    Name = "${var.environment_name}-nat-eip-1"
  }
}

resource "aws_eip" "nat_eip_2" {
  vpc = true

  tags = {
    Name = "${var.environment_name}-nat-eip-2"
  }
}



########################## Create NAT Gateways  #############################
resource "aws_nat_gateway" "nat_gw_1" {
  allocation_id = aws_eip.nat_eip_1.id
  subnet_id     = aws_subnet.public_subnet_1.id    
    tags = {
        Name = "${var.environment_name}-nat-gw-1"
    }
}


resource "aws_nat_gateway" "nat_gw_2" {
  allocation_id = aws_eip.nat_eip_2.id
  subnet_id     = aws_subnet.public_subnet_2.id    
    tags = {
        Name = "${var.environment_name}-nat-gw-2"
    }
}


########################### Create Route Tables  #############################
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id  
    tags = {
        Name = "${var.environment_name}-public-rt"
    }
}


resource "aws_route_table" "private_rt_1" {
  vpc_id = aws_vpc.vpc.id  
    tags = {
        Name = "${var.environment_name}-private-rt"
    }
}

resource "aws_route_table" "private_rt_2" {
  vpc_id = aws_vpc.vpc.id  
    tags = {
        Name = "${var.environment_name}-private-rt"
    }
}


############################ Create Routes  #############################
resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}


resource "aws_route" "private_route_1" {
  route_table_id         = aws_route_table.private_rt_1.id
  destination_cidr_block = "0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw_1.id
}

resource "aws_route" "private_route_2" {
  route_table_id         = aws_route_table.private_rt_2.id
  destination_cidr_block = "0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw_2.id
}


########################### Associate Subnets with Route Tables  #############################
resource "aws_route_table_association" "public_subnet_1_assoc" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_subnet_2_assoc" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
} 

resource "aws_route_table_association" "private_subnet_1_assoc" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_rt_1.id
}

resource "aws_route_table_association" "private_subnet_2_assoc" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_rt_2.id
}