# RESOURCES
# S3 Bucket
resource "aws_s3_bucket" "bucket" {
  bucket = "${var.domain_name}"
  acl    = "public-read"
  region = "${var.aws_region}"

  # Optional, I tag all my resources with the project they are associated with
  tags = {
    project = "${var.project_tag}"
  }

  # Set up static site hosting in S3
  website {
    index_document = "index.html"
    error_document = "index.html"
  }

  # Add domain to CORS
  cors_rule {
    allowed_methods = ["GET"]
    allowed_origins = ["${var.domain_name}"]
  }
}

# ---------------------------------------------------------------
# Upload files to S3
# ---------------------------------------------------------------
# So - I was exploring various ways to deploy my code here.
# But I think I've come to the conclusion that for this particular project,
#   it isn't Terraform's responsibility to upload the project code to S3.
#   This is reflected by the fact that there isn't really a good way of
#   doing this, on multiple levels.
# First of all, whereabouts in this configuration would I perform the build
#   step of compiling the code before deploying?
# Secondly, the `aws_s3_bucket_object` resource only refers to a single file,
#   it cannot upload a whole directory (this will change in Terraform 0.12.8
#   with `fileset`).
# I have come to the conclusion that, for now, the intended workflow for hosting
#   a static site in S3 is to set up the infrastructure using Terraform,
#   and then use your own automation to build and deploy it - AWS already
#   has its own tooling for this - such as the AWS CLI's "s3 sync" command.
# Terraform does not manage the entire lifecycle of your application, its
#   role is in infrastructure provisioning and management, NOT the packaging
#   or deployment of your code. Sometimes your code IS your infrastructure, and
#   these steps are one-in-the-same, e.g. hosting a .NET application on Lambda.
#   You create the lambda by deploying your code to it – a Lambda cannot exist
#   without code to run, and there is only one "application" to run on the
#   lambda, it either has one or it doesn't. But S3 is a special case wherein you
#   can add-to or remove-from a set spanning from millions of files to
#   nothing - all of which are perfectly valid setups.
# See Hashicorp's own video about Application Delivery here:
#   https://youtu.be/wyRtz_tdJes
#   which talks about Terraform's role in an application's full lifecycle.
# Below are some of options I explored for deploying your code to S3
#   using Terraform.
#


# ---------------------------------------------------------------
# Code Deployment Option 1: Shell out to a build & deploy script
# Problems:
#   - Terraform does not know when to invalidate this resource
#   - We need to manage our own `depends_on` links as this isn't
#     part of Terraform's lifecycle
# Benefits:
#   - Basically works pretty well
#   - Can pass infrastructure information into our script e.g. bucket ID
# ---------------------------------------------------------------
# resource "null_resource" "remove_and_upload_to_s3" {
#   provisioner "local-exec" {
#     environment = {
#       BUCKET_ID             = "${aws_s3_bucket.bucket.id}"
#       AWS_ACCESS_KEY_ID     = "${var.aws_access_key}"
#       AWS_SECRET_ACCESS_KEY = "${var.aws_secret_key}"
#     }
#
#     command = "build-and-deploy-website.sh"
#   }
# }


# ------------------------------------------------------------
# Code Deployment Option 2: Manually specify files for upload
# Problems:
#   - Infeasibly difficult once you get more than ~2 files
#     It's not programmatic at all, requires manual updating
#   - Requires manually specifying MIME types and filenames
#   - Lots and lots of the same code over-and-over
# Benefits:
#   - It's all part of Terraform's lifecycle - it can easily
#     keep track of all these resources explicitly
# ------------------------------------------------------------
# resource "aws_s3_bucket_object" "index_html" {
#   bucket = "${aws_s3_bucket.bucket.id}"
#   key    = "index.html"
#   acl    = "public-read"
#   source = "index.html"
#   content_type = "text/html"
# }


# -----------------------------------------------------------
# Code Deployment Options 3: Use 0.12.8's `fileset` operator
# Problems:
#   - It's not out yet 😅
#   - Philosophically you are probably still using Terraform
#     to do something that isn't its responsibility.
#   - I'm unsure how will this will keep track of state in
#     the remote
# Benefits
#   - Lets you easily specify a glob of files to upload
#   - It's part of Terraform's lifecycle - shouldn't have
#     trouble keeping track of remote state
#   - Basically, this should be a perfectly viable option
# -----------------------------------------------------------
# resource "aws_s3_bucket_object" "app-files" {
#   for_each = fileset(path.module, "website/build/**/*")
#
#   bucket = aws_s3_bucket.bucket.id
#   key    = each.value
#   source = each.value
# }
