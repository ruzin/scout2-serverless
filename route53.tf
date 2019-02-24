resource "aws_acm_certificate" "scout2_ssl_cert" {
  provider          = "aws.route53"
  domain_name       = "*.${var.domain_name}"
  validation_method = "DNS"

  tags = {
    name = "scout2"
  }

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_route53_zone" "zone" {
  provider     = "aws.route53"
  name         = "${var.domain_name}."
  private_zone = false
}

resource "aws_route53_record" "scout2_ssl_cert_validation" {
  provider = "aws.route53"

  name    = "${aws_acm_certificate.scout2_ssl_cert.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.scout2_ssl_cert.domain_validation_options.0.resource_record_type}"
  zone_id = "${data.aws_route53_zone.zone.id}"
  records = ["${aws_acm_certificate.scout2_ssl_cert.domain_validation_options.0.resource_record_value}"]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "scout2_ssl_cert_validation" {
  provider = "aws.route53"

  certificate_arn         = "${aws_acm_certificate.scout2_ssl_cert.arn}"
  validation_record_fqdns = ["${aws_route53_record.scout2_ssl_cert_validation.fqdn}"]
}

resource "aws_route53_record" "scout2_website_recordset_group" {
  zone_id = "${data.aws_route53_zone.zone.id}"
  name    = "scout2-${lower(var.project_name)}-${lower(var.environment)}.${var.domain_name}"
  type    = "A"

  alias {
    name                   = "${aws_cloudfront_distribution.scout2_cloudfront_distribution.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.scout2_cloudfront_distribution.hosted_zone_id}"
    evaluate_target_health = false
  }
}
