variable "project" {
  type = string
}

variable "region" {
  type = string
}

variable "az" {
  type = string
}

variable "vpc_cidr" {
  type = string
  default = "10.20.0.0/16"
}