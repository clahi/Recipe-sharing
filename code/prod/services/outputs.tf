output "alb_dns_name" {
  value = module.application_load_balancer.alb_dns_name
  description = "the domain name of the load balancer"
}