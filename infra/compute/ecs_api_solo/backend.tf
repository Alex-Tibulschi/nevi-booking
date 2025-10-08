terraform {
    backend "s3" {
        bucket = "salon-booking-tfstate-eu-west-2-atj"
        key = "compute/ecs_api_solo/terraform.tfstate"
        region = "eu-west-1"
        dynamodb_table = "salon-booking-tf-lock"
        encrypt = true
    }

}