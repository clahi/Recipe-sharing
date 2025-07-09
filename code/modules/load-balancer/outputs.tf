output "alb_dns_name" {
  value = aws_lb.application_lb.dns_name
  description = "the domain name of the load balancer"
}

output "alb_http_listener_arn" {
  value = aws_lb_listener.http.arn
  description = "The ARN of the HTTP listener"
}

output "alb_security_group_id" {
  value = aws_security_group.alb.id
  description = "The ALB Security Group ID"
}

output "alb_target_group" {
  description = "The target group arn"
  value = aws_lb_target_group.asg_target_group.arn
}