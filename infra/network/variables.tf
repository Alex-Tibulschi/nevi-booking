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

variable "subnet1_cidr" {
  type = string
}

variable "subnet1_az" {
  type = string
}

variable "subnet2_cidr" {
  type = string
}

variable "subnet2_az" {
  type = string
}