#s3 bucket to store scout2 report
resource "aws_s3_bucket" "s3_scout2" {
  bucket        = "scout2-${random_string.name.result}"
  acl           = "private"
  force_destroy = true

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3600
  }

  website {
    index_document = "report.html"
    error_document = "report.html"
  }

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  logging {
    target_bucket = "${aws_s3_bucket.s3_scout2_logging.id}"
    target_prefix = "log/"
  }

  tags = {
    name = "scout2"
  }
}

#s3 bucket to log scout2 report bucket activity
resource "aws_s3_bucket" "s3_scout2_logging" {
  bucket        = "scout2-logging-${random_string.name.result}"
  acl           = "log-delivery-write"
  force_destroy = true

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    name = "scout2"
  }
}

#Lambda function run scout2 report
module "scout2_lambda" {
  source           = "git@github.com:ruzin/terraform_aws_lambda_python.git"
  output_path      = "scout2_lambda.zip"
  description      = "Lambda function to run scout2 reports against current AWS account"
  source_code_path = "${path.module}/lambda_scout2/"
  role_arn         = "${aws_iam_role.lambda_scout2_execution_role.arn}"
  function_name    = "scout2_report"
  handler_name     = "scout_report.lambda_handler"
  runtime          = "python3.6"
  timeout          = 300
  memory_size      = "3008"

  environment {
    variables = {
      REPORT_S3_STORAGE_NAME = "${aws_s3_bucket.s3_scout2.id}"
      REPORT_DIR             = "${var.report_prefix}/${var.project_name}/${var.environment}"
      CMD_ARGS               = "${var.cmd_args}"
      EXCEPTION_TESTS        = "${var.exception_tests}"
      PROJECT_NAME           = "${var.project_name}"
      ENVIRONMENT            = "${var.environment}"
    }
  }
}

#Permissions for cloudwatch event to invoke lambda function
resource "aws_lambda_permission" "allow_cloudwatch_scout_report" {
  statement_id  = "ScoutReportAllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${module.scout2_lambda.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${module.aws_cloudwatch_lambda_trigger.event_rule}"
}

#Cloudwatch trigger scheduled to run the scout2 lambda function on a daily basis
module "aws_cloudwatch_lambda_trigger" {
  source      = "./cloudwatch_trigger"
  lambda_arn  = "${module.scout2_lambda.arn}"
  lambda_name = "${module.scout2_lambda.function_name}"
  schedule    = "${var.run_schedule}"
}
