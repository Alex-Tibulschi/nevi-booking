locals {
  name_prefix = "${var.project}-net"
}



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

output "subnet1_id" {
  value = aws_subnet.subnet1.id
}
output "subnet1_cidr" {
  value = aws_subnet.subnet1.cidr_block
}