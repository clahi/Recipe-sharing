locals {
  http_port = 80
  any_port = 0
  any_protocol = "-1"
  tcp_protocl = "tcp"
  all_ips = ["0.0.0.0/0"]
}

resource "aws_launch_template" "server_cluster" {
  name = "${var.cluster_name}-lauch-template"
  image_id = var.ami
  instance_type = var.instance_type
  
  vpc_security_group_ids = [aws_security_group.allow_web_traffic.id]

  instance_initiated_shutdown_behavior = "terminate"

  user_data = var.user_data
}

resource "aws_autoscaling_group" "asg" {
  name = var.cluster_name
  max_size = var.max_size
  min_size = var.min_size

  launch_template {
    id = aws_launch_template.server_cluster.id
  }

  # The subnets to deploy the ec2 server, which in this case should be the private subnets
  vpc_zone_identifier = var.subnet_ids

  # configure integrations with a load balancer
  target_group_arns = var.target_group_arns
  health_check_type = var.health_check_type

  tag {
    key = "Name"
    value = "${var.cluster_name}-asg"
    propagate_at_launch = true
  }

  # Use instance refresh to roll out changes to the ASG
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }
}

# A security group that allows http & https traffic
resource "aws_security_group" "allow_web_traffic" {
  name = "${var.cluster_name}-sg"
  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "allow_http" {
  type = "ingress"
  security_group_id = aws_security_group.allow_web_traffic.id

  from_port = 80
  to_port = 80
  protocol = local.tcp_protocl
  cidr_blocks = local.all_ips
}

resource "aws_security_group_rule" "allow_https" {
  type = "ingress"
  security_group_id = aws_security_group.allow_web_traffic.id

  from_port = 443
  to_port = 443
  protocol = local.tcp_protocl
  cidr_blocks = local.all_ips
}

resource "aws_security_group_rule" "allow_outgoing" {
  type = "engress"
  security_group_id = aws_security_group.allow_web_traffic.id

  from_port = 0
  to_port = 0
  protocol = local.any_protocol
  cidr_blocks = local.all_ips
}