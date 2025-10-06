terraform {
    backend "s3" {
        bucket = "salon-booking-tfstate-eu-west-2-atj"
        key = "data/rds-subnet-group/terraform.tfstate"
        region = "eu-west-1"
        dynamodb_table = "salon-booking-tf-lock"
        encrypt = true
    }

}