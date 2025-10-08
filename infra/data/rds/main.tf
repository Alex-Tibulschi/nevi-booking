locals {
  name_prefix = "${var.project}-db"
}

#--------- Security Group: DB allows 5432 only from ECS task SG ---------

resource "aws_security_group" "db" {
  name = "${local.name_prefix}-sg"
  description = "Postgres ingress from ECS task SG only"
  vpc_id = var.vpc_id

  ingress {
    description = "Postgres from ECS task"
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    security_groups = [var.ecs_task_sg_id]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name_prefix}-sg",
    Project = var.project,
    Env = "dev"
  }
}


#---------- Random password - TODO: move to Secrets Manager ----------
resource "random_password" "db" {
  length = 20
  special = true
}

#---------- Parameter group (optional:default) ----------
resource "aws_db_parameter_group" "pg" {
  name = "${local.name_prefix}-params"
  family = "postgres16"
  tags = {
    Project = var.project,
    Env = "dev"
  }
}

#---------- RDS instance (single-AZ, private) ----------
resource "aws_db_instance" "this" {
  identifier = "${local.name_prefix}-instance"
  engine = "postgres"
  engine_version = var.db_engine_version
  instance_class = var.db_instance_class
  db_subnet_group_name = "nevi-booking-db-subnets"
  vpc_security_group_ids = [aws_security_group.db.id]
  publicly_accessible = false
  allocated_storage = 20
  storage_type = "gp3"
  storage_encrypted = true

  db_name = var.db_name
  username = "appuser"
  password = random_password.db.result
  port = 5432

  multi_az = false
  backup_retention_period = var.backup_retention
  deletion_protection = false
  skip_final_snapshot = true

  apply_immediately = true
  parameter_group_name = aws_db_parameter_group.pg.name

  tags = {
    Name = "${local.name_prefix}",
    Project = var.project,
    Env = "dev"
  }
}

#---------- Outputs ----------
output "db_endpoint" {
  value = aws_db_instance.this.address
}
output "db_port" {
  value = aws_db_instance.this.port
}
output "db_name" {
  value = var.db_name
}
output "db_username" {
  value = aws_db_instance.this.username
}
output "db_sg_id" {
  value = aws_security_group.db.id
}

#TEMPORARY - TODO: REMOVE THIS
output "db_password" {
  value = random_password.db.result
  sensitive = true
}