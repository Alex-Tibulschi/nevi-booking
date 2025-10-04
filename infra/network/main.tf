locals {
  name_prefix = "${var.project}-net"
}


# VPC 1
resource "aws_vpc" "this" {
    cidr_block = var.vpc_cidr
    enable_dns_support = true
    enable_dns_hostnames = true

    tags = {
      Name = "${local.name_prefix}-vpc"
      Project = var.project
      Env = "dev"
    }
}

output "vpc_id" {
  value = aws_vpc.this.id
}

output "vpc_cidr" {
  value = var.vpc_cidr
}


# Subnet 1 attached to VPC1
resource "aws_subnet" "subnet1" {
  vpc_id = aws_vpc.this.id
  cidr_block = var.subnet1_cidr
  availability_zone = var.subnet1_az

  map_public_ip_on_launch = true

  tags = {
    Name = "${local.name_prefix}-subnet1"
    Project = var.project
    Env = "dev"
    AZ = var.subnet1_az
  }
}

output "public_subnet1_id" {
  value = aws_subnet.subnet1.id
}
output "public_subnet1_cidr" {
  value = aws_subnet.subnet1.cidr_block
}

# Internet Gateway attached to VPC1
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${local.name_prefix}-igw"
    Project = var.project
    Env = "dev"
  }
}

output "igw_id" {
  value = aws_internet_gateway.igw.id
}

# Route table for public access
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${local.name_prefix}-rt-public"
    Project = var.project
    Env = "dev"
  }
}

output "public_rt_id" {
  value = aws_route_table.public.id
}

# Default route - 0.0.0.0/0 to the IGW
resource "aws_route" "public_default" {
  route_table_id = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}

# Associate route table to subnet
resource "aws_route_table_association" "subnet1_assoc" {
  subnet_id = aws_subnet.subnet1.id
  route_table_id = aws_route_table.public.id
}

# Private subnet
resource "aws_subnet" "subnet2" {
  vpc_id = aws_vpc.this.id
  cidr_block = var.subnet2_cidr
  availability_zone = var.subnet2_az

  map_public_ip_on_launch = false

  tags = {
    Name = "${local.name_prefix}-subnet2-private"
    Project = var.project
    Env = "dev"
    AZ = var.subnet2_az
    Tier = "private"
  }
}

output "private_subnet2_id" {
  value = aws_subnet.subnet2.id
}

# Private route table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${local.name_prefix}-rt-private"
    Project = var.project
    Env = "dev"
  }
}

# Private route table association with subnet2
resource "aws_route_table_association" "subnet2_assoc" {
  subnet_id = aws_subnet.subnet2.id
  route_table_id = aws_route_table.private.id
}

output "private_rt_id" {
  value = aws_route_table.private.id
}