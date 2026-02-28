resource "aws_s3_bucket" "user_data" {
  bucket = "allicator-userdata-${terraform.workspace}"
}