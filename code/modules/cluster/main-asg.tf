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
}