variable "whitelisted_ips" {
  type        = "list"
  description = "List of whitelisted ip addresses"

  default = [{
    value = "192.142.80.231/32"

    type = "IPV4"
  }]
}
