# Terraform - Static site hosted on AWS

Use AWS to host a basic static website deployed and managed using Terraform. The website itself is a dummy site from [this project](https://github.com/peabnuts123/dummy-web-app).

## Infrastructure plan

The architecture for hosting this project is as follows:

  - Host site data in an S3 bucket
  - Use CloudFront CDN to serve and cache requests to the site
    - Setup redirect rules for all failed requests to serve `index.html` HTTP 200 (for single page app behaviour)
    - CloudFront's caches are spread around the world for fast performance internationally
  - (Out of scope/manual) CNAME DNS record on domain to point at CloudFront
    - (Out of scope/manual) [AWS ACM](https://aws.amazon.com/certificate-manager/) for provisioning an HTTPS certificate for this domain
  - (Optional) AWS CLI S3 Sync for deploying application code

## Prerequisites

You will need to have the following in order to begin
 - [Node.js](https://nodejs.org) installed (for running and installing `meta`)
 - `npm i -g meta` to install `meta`
 - Terraform installed and available in your path
 - (Optional) The [AWS CLI](https://aws.amazon.com/cli/), for automatically uploading the website code to S3

## Setting up and deploying the project

1. Clone this repo using `git clone ...`
1. Clone the website subproject using `meta git update`
1. Set up Terraform variables using `cp example.tfvars terraform.tfvars` and filling out the values in the `terraform.tfvars` file
1. Initialize Terraform using `terraform init` (this will install providers)
1. Run `terraform plan` to see what changes will be made
1. Run `terraform apply` and then type `yes` to deploy the configuration!
1. (Optional) Run `build-and-deploy-website.sh` to build the project and upload it to the S3 bucket. **NOTE: You will need to configure some environment variables in-order to run this script. See the top of `build-and-deploy-website.sh` for details**

## Terraform and deploying application code

In this project, Terraform does not deploy the application's code to S3, it merely provisions the infrastructure needed for hosting it. I spent a bit of time investigating ways to achieve this, but ultimately I decided that this was not Terraform's responsibility in the application delivery lifecycle. This is signalled by the fact that it's not easy to do, in a few different ways.

Firstly, there's no good way to insert a build / compilation step into your Terraform plan. You might think about your code as a data block or some kind of local resource, but Terraform doesn't offer much in the way of modelling this. The [external](https://www.terraform.io/docs/providers/external/data_source.html) data source and the [local_exec](https://www.terraform.io/docs/provisioners/local-exec.html) provisioner can be used to call-out to external applications, but it can be hard to loop-back into Terraform's lifecycle. Secondly, the AWS provider doesn't offer any good way of uploading a directory of files to an S3 bucket. It only has a resource for uploading specific files by name, so that Terraform can carefully track the state of each of those objects. There are a few approaches for deploying the application code to S3 detailed in `bucket.tf` with pros and cons for each if you feel like reading about this in further detail.

For the purposes of this project, a simple shell script, `build-and-deploy-website.sh`, has been written for managing building and deploying the application code to existing infrastructure. The idea here would be that, if this application were part of a more-complete application delivery lifecycle, you would have a suite of automation in-place anyway (e.g. testing, packaging, monitoring), and that you should be using that for the packaging and deploying your application code. See [Hashicorp's own video](https://youtu.be/wyRtz_tdJes) on application delivery for an example of how Terraform is intended to fit into a workflow.