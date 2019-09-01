# Rename or copy this file to `terraform.tfvars` and populate config values

# AWS
# For access to AWS.
# IAM user will need the following permissions:
#   - AmazonS3FullAccess
#   - CloudFrontFullAccess
#   - AWSCertificateManagerFullAccess
aws_access_key=""
aws_secret_key=""

# General
# AWS region to create resources in
aws_region="us-east-1"
# Domain of the site that will be serving this distribution
domain_name=""
# I tag all my resources with the project they are associated with
# Optional, but you will have to remove references to it if you don't
#   want to use it.
project_tag=""