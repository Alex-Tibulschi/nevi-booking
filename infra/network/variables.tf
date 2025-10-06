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

# Public subnet 1
variable "subnet1_cidr" {
  type = string
}

variable "subnet1_az" {
  type = string
}

# Private subnet 1
variable "subnet2_cidr" {
  type = string
}

variable "subnet2_az" {
  type = string
}

# API ingress ports ONLY TO LEARN THE SETUP
variable "api_http_ports" {
  type = list(number)
  default = [ 80, 443 ]
}

# Database port (PostGres)
variable "db_port" {
  type = number
  default = 5432
}

# Second private subnet for availability
variable "subnet3_cidr" {
  type = string
}

variable "subnet3_az" {
  type = string
}