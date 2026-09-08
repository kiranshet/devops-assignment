terraform {
  backend "s3" {
    bucket         = "devops-assignment-terraform-state-620893829052"
    key            = "dev/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "devops-assignment-terraform-locks"
    encrypt        = true
  }
}