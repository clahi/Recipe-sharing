locals {
  http_port = 80
  any_port = 0
  any_protocol = "-1"
  tcp_protocol = "tcp"
  all_ips = ["0.0.0.0/0"]
}

# An application Load Balancer to balance the tarrafic from CloudFront
resource "aws_lb" "application_lb" {
  name = var.alb_name
  load_balancer_type = "application"
  subnets = var.subnet_ids
  security_groups    = [aws_security_group.alb.id]
}

# Security group for ALB to allow access from 80 & 443
resource "aws_security_group" "alb" {
  name = var.alb_name
  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "allow_http" {
  type = "ingress"
  security_group_id = aws_security_group.alb.id

  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = local.all_ips
}

resource "aws_security_group_rule" "allow_https" {
  type = "ingress"
  security_group_id = aws_security_group.alb.id

  from_port = 443
  to_port = 443
  protocol = "tcp"
  cidr_blocks = local.all_ips
}

resource "aws_security_group_rule" "allow_all_outbound" {
  type = "egress"
  security_group_id = aws_security_group.alb.id

  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = local.all_ips
}

# Creating a listener for the Alb
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.application_lb.arn
  port = local.http_port
  protocol = "HTTP"

  # By default, return a simple 404 page
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code = 404
    }
  }
}

# A target group for the which will instances in ASG
resource "aws_lb_target_group" "asg_target_group" {
  name = var.alb_name
  # port = var.server_port
  port = 8080
  protocol = "HTTP"
  vpc_id = var.vpc_id

  health_check {
    path = "/"
    protocol = "HTTP"
    matcher = "200"
    interval = 15
    timeout = 3
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
}

# A listener rule for the ALB
resource "aws_lb_listener_rule" "alb_listener_rule" {
  listener_arn = aws_lb_listener.http.arn
  priority = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.asg_target_group.arn
  }
}