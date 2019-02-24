#random string
resource "random_string" "name" {
  length  = 4
  special = false
  upper   = false
}
