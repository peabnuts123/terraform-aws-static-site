# DATA
# Certificate from ACM - this is configured (once) by hand on the AWS website
data "aws_acm_certificate" "cert" {
  domain = "${var.domain_name}"
}
