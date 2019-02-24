#Provider to create scout2 resources in eu-west-1
provider "aws" {
  region  = "eu-west-1"
  profile = "${var.scout2_aws_profile}"
}

#Provider to create lambda@edge resource in us-east-1 as it is only currently available in this region.
provider "aws" {
  alias   = "us-east-1"
  region  = "us-east-1"
  profile = "${var.scout2_aws_profile}"
}

#Provider to create ACM and route53 resources
provider "aws" {
  alias   = "route53"
  region  = "us-east-1"
  profile = "${var.route53_aws_profile}"
}
