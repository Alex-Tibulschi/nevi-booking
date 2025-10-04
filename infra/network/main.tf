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