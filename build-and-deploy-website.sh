#!/usr/bin/env bash
# SYNC PROJECT TO S3
# Build and upload the project to the a specified S3 bucket
# Configure the following environment variables for this script to run:
#
# BUCKET_ID               - ID of the S3 bucket to upload the built assets to
# AWS_ACCESS_KEY_ID       - AWS CLI - access key
# AWS_SECRET_ACCESS_KEY   - AWS CLI - secret key
#
# This script also assumes you have the AWS CLI installed:
#   https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html
#
# Alternatively, you could just upload these resources by hand using the website,
#   this script is just a convenience function.

# Assert environment variables are set
echo "Bucket ID: ${BUCKET_ID}";
echo "AWS_ACCESS_KEY_ID: ${AWS_ACCESS_KEY_ID}"

# Build project
cd website || exit 1;
npm i;
npm run build;

# Upload to S3 bucket
aws s3 sync './build/' "s3://${BUCKET_ID}" --acl 'public-read';
