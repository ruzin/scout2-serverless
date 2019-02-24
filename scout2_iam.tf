#lambda_scout2 IAM roles & polciies
resource "aws_iam_role" "lambda_scout2_execution_role" {
  name               = "lambda_scout2_execution_role"
  assume_role_policy = "${data.aws_iam_policy_document.lambda_scout2_assume_role_policy_document.json}"
}

resource "aws_iam_role_policy_attachment" "lambda_scout2_execution_role_policy_attachment" {
  role       = "${aws_iam_role.lambda_scout2_execution_role.name}"
  policy_arn = "${aws_iam_policy.lambda_scout2_execution_role_policy.arn}"
}

resource "aws_iam_policy" "lambda_scout2_execution_role_policy" {
  name   = "lambda_scout2_execution_role_policy"
  policy = "${file("${path.module}/policies/scout2_execution_policy.json")}"
}

data "aws_iam_policy_document" "lambda_scout2_assume_role_policy_document" {
  statement {
    effect = "Allow"

    principals {
      type = "Service"

      identifiers = [
        "lambda.amazonaws.com",
      ]
    }

    actions = ["sts:AssumeRole"]
  }
}

#Bucket polciies for cloudfront access to s3
data "aws_iam_policy_document" "s3_storage_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.scout2_origin_access_identity.iam_arn}"]
    }

    actions   = ["s3:Listbucket"]
    resources = ["${aws_s3_bucket.s3_scout2.arn}"]
  }

  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.scout2_origin_access_identity.iam_arn}"]
    }

    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.s3_scout2.arn}/*"]
  }

  statement {
    effect = "Deny"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions   = ["s3:GetObject", "s3:Listbucket"]
    resources = ["${aws_s3_bucket.s3_scout2.arn}/*", "${aws_s3_bucket.s3_scout2.arn}"]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"

      values = [
        "false",
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "s3_storage_policy" {
  bucket = "${aws_s3_bucket.s3_scout2.id}"
  policy = "${data.aws_iam_policy_document.s3_storage_policy.json}"
}
