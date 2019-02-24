# Setup a cloudwatch event to trigger a lambda function

# Inputs:
variable "lambda_arn" {
  description = "The ARN of the lambda function (aws_lambda_function.<function>.arn)"
}

variable "lambda_name" {
  description = "The lambda function name (aws_lambda_function.<function>.function_name)"
}

variable "schedule" {
  type        = "string"
  description = "A cloudwatch schedule expression. Supports both cron(..) and rate(..) syntax"
}

variable "target_input" {
  description = "Valid JSON text passed to the target"
  default     = ""
}

variable "event_rule" {
  description = "Custom event rule name. Generated from the lambda name + schedule by default. Max 64 chars"
  default     = ""
}

variable "description" {
  description = "Custom cloudwatch description."
  default     = ""
}

# Outputs:
output "event_rule" {
  value = "${aws_cloudwatch_event_rule.event_rule.arn}"
}
