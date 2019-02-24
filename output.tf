output "scout2_domain_name" {
  description = "scout2 static website url"
  value       = "scout2-${lower(var.project_name)}-${lower(var.environment)}.${var.domain_name}"
}
