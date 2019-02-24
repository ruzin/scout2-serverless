variable "project_name" {
  description = "Name of the project"
}

variable "environment" {
  description = "Environment to be deployed into eg: dev,test or prod."
}

variable "run_schedule" {
  description = "run schedule for scout2 lambda function. Defaults to 1 hour i.e. function is invoked daily."
  default     = "rate(1 hour)"
}

variable "cmd_args" {
  default = "--force,--thread-config,3,--no-browser"
}

variable "exception_tests" {
  default = ""
}

variable "username" {
  description = "Username for scout2 basic auth. Defaults to scout2."
  default     = "scout2"
}

variable "password" {
  description = "Password for scout2."
}

variable "runtime" {
  description = "python runtime. Defaults to python3.6"
  default     = "python3.6"
}

variable "scout2_aws_profile" {
  description = "aws profile name for provisioning scout2 resources. Must have required access."
}

variable "route53_aws_profile" {
  description = "aws profile name for provisioning route53 & acm resources. Must have required access to provision route53/acm resources."
}

variable "report_prefix" {
  default = "/tmp"
}

variable "domain_name" {
  description = "Route53 domain name."
}

variable "whitelisted_ips" {
  type        = "list"
  description = "List of whitelisted ip addresses."
}
