variable "project" {
  type = string
}

variable "region" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "ecr_image" {
  type = string
}

variable "container_port" {
  type = number
  default = 8000
}

variable "cpu" {
  type = number
  default = 256
}

variable "memory" {
  type = number
  default = 512
}