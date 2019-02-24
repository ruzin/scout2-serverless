## Purpose
The module provisions a secure s3 static website with basic http auth to serve scout2 pen test reports.

## Architecture
![Alt text](images/architecture.jpg?raw=true "Title")

## Pre-requisites
- Provision a Route53 Public Hosted Zone, ideally in a central services AWS account
- AWS Profile with access to Route53 & AWS Certificate Manager Resources in all regions in the central services AWS account
- AWS Profile with access to Cloudfront, S3, Lambda, IAM & AWS WAF Resources in all regions in the NonProd AWS account i.e.
  account you will be generating scout2 reports for
  
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| domain\_name | Route53 domain name. | string | n/a | yes |
| environment | Environment to be deployed into eg: dev,test or prod. | string | n/a | yes |
| password | Password for scout2. | string | n/a | yes |
| project\_name | Name of the project | string | n/a | yes |
| route53\_aws\_profile | aws profile name for provisioning route53 & acm resources. Must have required access to provision route53/acm resources. | string | n/a | yes |
| scout2\_aws\_profile | aws profile name for provisioning scout2 resources. Must have required access. | string | n/a | yes |
| whitelisted\_ips | List of whitelisted ip addresses. | list | n/a | yes |
| cmd\_args |  | string | `"--force,--thread-config,3,--no-browser"` | no |
| exception\_tests |  | string | `""` | no |
| report\_prefix |  | string | `"/tmp"` | no |
| run\_schedule | run schedule for scout2 lambda function. Defaults to 1 hour i.e. function is invoked daily. | string | `"rate(1 hour)"` | no |
| runtime | python runtime. Defaults to python3.6 | string | `"python3.6"` | no |
| username | Username for scout2 basic auth. Defaults to scout2. | string | `"scout2"` | no |

## Outputs

| Name | Description |
|------|-------------|
| scout2\_domain\_name | scout2 static website url |
