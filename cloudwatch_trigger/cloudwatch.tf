locals {
  default_event_rule = "${var.lambda_name}_${md5("${var.target_input}${var.schedule}")}"

  default_description = "Trigger the ${var.lambda_name} lambda"
}

resource "aws_cloudwatch_event_rule" "event_rule" {
  name                = "${var.event_rule == "" ? local.default_event_rule : var.event_rule}"
  description         = "${var.description == "" ? local.default_description : var.description}"
  schedule_expression = "${var.schedule}"
}

resource "aws_cloudwatch_event_target" "event_target" {
  rule      = "${aws_cloudwatch_event_rule.event_rule.name}"
  target_id = "${var.lambda_name}_lambda_target"
  arn       = "${var.lambda_arn}"
  input     = "${var.target_input}"
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "${aws_cloudwatch_event_rule.event_rule.name}"
  action        = "lambda:InvokeFunction"
  function_name = "${var.lambda_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.event_rule.arn}"
}
