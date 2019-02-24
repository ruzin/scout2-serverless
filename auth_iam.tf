#IAM roles and policies for Lambda@edge authorisation Lambda function
data "aws_iam_policy_document" "lambda_auth_assume_role_policy_document" {
  statement {
    effect = "Allow"

    principals {
      type = "Service"

      identifiers = [
        "edgelambda.amazonaws.com",
        "lambda.amazonaws.com",
      ]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "lambda_auth_execution_role_policy_document" {
  statement {
    effect    = "Allow"
    actions   = ["logs:*"]
    resources = ["arn:aws:logs:*:*:*"]
  }
}

resource "aws_iam_role" "lambda_auth_execution_role" {
  name = "lambda_auth_execution_role"

  assume_role_policy = "${data.aws_iam_policy_document.lambda_auth_assume_role_policy_document.json}"
  path               = "/service/"
  description        = "scout2 - Basic Auth @Edge Lambda Execution Role"
}

resource "aws_iam_role_policy" "lambda_auth_execution_role_policy" {
  name   = "lambda_auth_execution_role_policy"
  role   = "${aws_iam_role.lambda_auth_execution_role.id}"
  policy = "${data.aws_iam_policy_document.lambda_auth_execution_role_policy_document.json}"
}
