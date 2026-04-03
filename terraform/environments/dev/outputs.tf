output "frontend_url" {
  value = "http://${module.cloudfront.domain_name}"
}

output "api_url" {
  value = "http://${module.alb.alb_dns_name}"
}

output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "cloudfront_domain_name" {
  value = module.cloudfront.domain_name
}

output "jenkins_public_ip" {
  value = module.jenkins.public_ip
}

output "db_endpoint" {
  value = module.rds.db_endpoint
}
