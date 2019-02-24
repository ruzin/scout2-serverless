#Cloudfront origin access identity
resource "aws_cloudfront_origin_access_identity" "scout2_origin_access_identity" {
  comment = "${var.project_name}.${var.environment}-scout2-Origin Access Identity"
}

#scout2 cloudfront distribution
resource "aws_cloudfront_distribution" "scout2_cloudfront_distribution" {
  depends_on = ["aws_acm_certificate_validation.scout2_ssl_cert_validation"]
  web_acl_id = "${aws_waf_web_acl.scout2_waf_web_acl.id}"
  aliases    = ["scout2-${lower(var.project_name)}-${lower(var.environment)}.${var.domain_name}"]

  origin {
    domain_name = "${aws_s3_bucket.s3_scout2.bucket_domain_name}"
    origin_id   = "s3Origin"

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.scout2_origin_access_identity.cloudfront_access_identity_path}"
    }
  }

  enabled             = "True"
  comment             = "${var.project_name}.${var.environment}-scout2-static-site"
  default_root_object = "report.html"

  logging_config {
    include_cookies = false
    bucket          = "${aws_s3_bucket.s3_scout2_logging.bucket_domain_name}"
    prefix          = "cloudfront/"
  }

  default_cache_behavior {
    allowed_methods = [
      "GET",
      "HEAD",
    ]

    cached_methods = [
      "GET",
      "HEAD",
    ]

    target_origin_id = "s3Origin"

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  ordered_cache_behavior {
    path_pattern = "*"

    allowed_methods = [
      "GET",
      "HEAD",
    ]

    cached_methods = [
      "GET",
      "HEAD",
    ]

    target_origin_id = "s3Origin"

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    lambda_function_association {
      event_type = "viewer-request"
      lambda_arn = "${aws_lambda_function.scout2_basic_auth_lambda.qualified_arn}"
    }
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["GB"]
    }
  }

  viewer_certificate {
    acm_certificate_arn = "${aws_acm_certificate.scout2_ssl_cert.arn}"
    ssl_support_method  = "sni-only"
  }

  tags = {
    name = "scout2"
  }
}
