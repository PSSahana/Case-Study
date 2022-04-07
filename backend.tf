terraform {
  backend "s3" {
    bucket = "govtech-bucket-1234"
    key    = "remote.tfstate"
    region = "ap-southeast-1"
    #dynamodb_table = "terraformstatelocktable"
  }
}
