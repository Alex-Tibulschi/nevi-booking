variable "project" {
  description = "Project name prefix for resources"
  type = string
}

variable "region" {
  description = "AWS Region"
  type = string
}

variable "services_table_name" {
  description = "Name of the DynamoDB services table"
  type = string
}

variable "bookings_table_name" {
  description = "Name of the DynamoDB bookings table"
  type = string
}

