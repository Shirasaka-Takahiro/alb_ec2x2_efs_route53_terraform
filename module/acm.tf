##ACM
resource "aws_acm_certificate" "cert_alb" {
  #domain_name = "*.${var.zone_name}"
  domain_name = "*.onya-lab.site"
  #subject_alternative_names = ["${var.zone_name}"]
  subject_alternative_names = ["onya-lab.site"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

##Create cname record for alb on Route53
resource "aws_route53_record" "cert_validation_alb" {
  for_each = {
    for dvo in aws_acm_certificate.cert_alb.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  type            = each.value.type
  ttl             = "300"
  #zone_id = aws_route53_zone.primary_zone.zone_id
  zone_id = "Z07403921OYE516WPU79B"
}