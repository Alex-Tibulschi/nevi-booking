locals {
  name_prefix = "${var.project}-db"
}

resource "aws_db_subnet_group" "db" {
  name = "${local.name_prefix}-subnets"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${local.name_prefix}-subnets"
    Project = var.project
    Env = "dev"
  }
}

output "rds_subnet_group_name" {
  value = aws_db_subnet_group.db.name
}