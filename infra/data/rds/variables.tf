variable "project" {
  type = string
}

variable "region" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "ecs_task_sg_id" {
  type = string
}

#DB basics
variable "db_engine_version" {
  type = string
  default = "16.3"
}

variable "db_instance_class" {
  type = string
  default = "db.t4g.micro"
}

variable "db_name" {
  type = string
  default = "salon"
}

variable "backup_retention" {
  type = number
  default = 1
}