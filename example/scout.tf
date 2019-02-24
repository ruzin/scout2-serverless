provider "vault" {
  address = "https://vault.co.uk"
}

data "vault_generic_secret" "scout2" {
  path = "secret/scout2"
}

module "scout2" {
  source             = "git@github.com:ruzin/scout2-serverless.git"
  project_name       = "sandbox"
  environment        = "dev"
  scout2_aws_profile = "aws_profile_sandbox_dev"

  #providing password from secrets management tool like vault is recommended. Try not to hardcode secrets!
  password            = "${data.vault_generic_secret.scout2.data["password"]}"
  route53_aws_profile = "aws_profile_route53"
  domain_name         = "example.com"
  whitelisted_ips     = "${var.whitelisted_ips}"
}
