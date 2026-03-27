resource "aws_route53_record" "frontend" {
  zone_id = var.zone_id
  name    = var.frontend_record_name
  type    = "A"

  alias {
    name                   = var.frontend_domain_name
    zone_id                = var.frontend_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "api" {
  zone_id = var.zone_id
  name    = var.api_record_name
  type    = "A"

  alias {
    name                   = var.api_domain_name
    zone_id                = var.api_zone_id
    evaluate_target_health = true
  }
}
