# VARIABLES
variable "aws_access_key" {
  description = "AWS access key"
  type        = "string"
}
variable "aws_secret_key" {
  description = "AWS secret key"
  type        = "string"
}


# PROVIDER
provider "aws" {
  region     = "${var.aws_region}"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}
