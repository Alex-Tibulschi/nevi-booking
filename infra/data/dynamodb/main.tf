# A table for all salon services
resource "aws_dynamodb_table" "services" {
  name = var.services_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Project = var.project
    Env = "dev"
  }
}

output "services_table_name" {
  value = aws_dynamodb_table.services.name
}

# A table for bookings
resource "aws_dynamodb_table" "bookings" {
  name = var.bookings_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "booking_id"

  attribute {
    name = "booking_id"
    type = "S"
  }

  ttl {
    attribute_name = "ttl_epoch"
    enabled = false
  }

  tags = {
    Project = var.project
    Env = "dev"
  }
}

output "bookings_table_name" {
  value = aws_dynamodb_table.bookings.name
}