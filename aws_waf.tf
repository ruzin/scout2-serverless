#AWS waf configuration
resource "aws_waf_ipset" "scout2_ipset" {
  name = "scout2_IPSet"

  ip_set_descriptors = "${var.whitelisted_ips}"
}

resource "aws_waf_rule" "scout2_wafrule" {
  depends_on  = ["aws_waf_ipset.scout2_ipset"]
  name        = "scout2WAFRule"
  metric_name = "scout2WAFRule"

  predicates {
    data_id = "${aws_waf_ipset.scout2_ipset.id}"
    negated = false
    type    = "IPMatch"
  }
}

#Web acl that blocks traffic based on ip-match
resource "aws_waf_web_acl" "scout2_waf_web_acl" {
  depends_on  = ["aws_waf_ipset.scout2_ipset", "aws_waf_rule.scout2_wafrule"]
  name        = "scout2WebACL"
  metric_name = "scout2WebACL"

  default_action {
    type = "BLOCK"
  }

  rules {
    action {
      type = "ALLOW"
    }

    priority = 1
    rule_id  = "${aws_waf_rule.scout2_wafrule.id}"
    type     = "REGULAR"
  }
}
