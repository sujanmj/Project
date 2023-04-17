terraform {
  backend "s3" {
    bucket = "mj-terra-bucket"
    key    = "terraform/backend"
    region = "us-east-1"
  }
}