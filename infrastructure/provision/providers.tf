terraform {
  backend "s3" {
    bucket         = "terraform-state"
    key            = "descomplica/terraform.tfstate"
    region         = "us-east-1"
    # Replace this with your DynamoDB table name!
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
  
}