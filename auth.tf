#Lambda function for basic auth
resource "aws_lambda_function" "scout2_basic_auth_lambda" {
  provider         = "aws.us-east-1"
  filename         = "auth_lambda.zip"
  function_name    = "scout2_basic_auth_${random_string.name.result}"
  role             = "${aws_iam_role.lambda_auth_execution_role.arn}"
  handler          = "index.handler"
  source_code_hash = "${data.archive_file.scout2_basic_auth_lambda_package.output_base64sha256}"
  runtime          = "nodejs6.10"
  description      = "scout2 - Basic Auth @Edge Lambda"
  memory_size      = 128
  timeout          = 1
  publish          = true

  tags = {
    name = "scout2"
  }
}

data "archive_file" "scout2_basic_auth_lambda_package" {
  depends_on  = ["null_resource.render_lambda_auth"]
  type        = "zip"
  source_dir  = "${path.module}/lambda_auth/"
  output_path = "auth_lambda.zip"
}

#Rendering function source code with username and password
data "template_file" "lambda_auth" {
  template = "${file("${path.module}/lambda_auth/index.js")}"

  vars = {
    username = "${var.username}"
    password = "${var.password}"
  }
}

resource "null_resource" "render_lambda_auth" {
  triggers {
    basic_auth_password = "${var.password}"
  }

  provisioner "local-exec" {
    command = "bash ${path.module}/scripts/render_lambda_auth.sh $data $path"

    environment {
      data = "${data.template_file.lambda_auth.rendered}"
      path = "${path.module}/lambda_auth/index.js"
    }
  }
}
