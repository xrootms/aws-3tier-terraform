variable "lb_name" {}
variable "is_external" { default = false }
variable "lb_type" {}
variable "sg_enable_ssh_https" {}
variable "subnet_ids" {}
variable "tag_name" {}
variable "lb_target_group_arn" {}
variable "ec2_instance_id" {}
variable "lb_target_group_attachment_port" {}
variable "lb_http_listner_port" {}
variable "lb_http_listner_protocol" {}
variable "lb_listner_default_action" {}
variable "lb_https_listner_port" {}
variable "lb_https_listner_protocol" {}
variable "srl_proj_dev_acm_arn" {}


output "aws_lb_dns_name" {
  value = aws_lb.srl_proj_dev_lb.dns_name
}

output "aws_lb_zone_id" {
  value = aws_lb.srl_proj_dev_lb.zone_id
}


resource "aws_lb" "srl_proj_dev_lb" {
    name               = var.lb_name
    internal           = var.is_external
    load_balancer_type = var.lb_type
    security_groups    = [var.sg_enable_ssh_https]
    subnets            = var.subnet_ids

    enable_deletion_protection = false

    tags = { Name = "example-lb" }
}

resource "aws_lb_target_group_attachment" "srl_proj_dev_lb_target_group_attachment" {
    target_group_arn = var.lb_target_group_arn
    target_id        = var.ec2_instance_id                   # Replace with your EC2 instance reference
    port             = var.lb_target_group_attachment_port   # tells the lb which port on the EC2 instance to send traffic to.
}

# http listner on port 80
resource "aws_lb_listener" "srl_proj_dev_proj_lb_http_listner" {
    load_balancer_arn = aws_lb.srl_proj_dev_lb.arn
    port              = var.lb_http_listner_port
    protocol          = var.lb_http_listner_protocol

    default_action {
        type = "redirect"
        redirect {
            port        = "443"
            protocol    = "HTTPS"
            status_code = "HTTP_301"
        }
    }
}

# https listner on port 443
resource "aws_lb_listener" "srl_proj_dev_lb_https_listner" {
    load_balancer_arn = aws_lb.srl_proj_dev_lb.arn
    port              = var.lb_https_listner_port
    protocol          = var.lb_https_listner_protocol
    ssl_policy        = "ELBSecurityPolicy-FS-1-2-Res-2019-08"
    certificate_arn   = var.srl_proj_dev_acm_arn

    default_action {
        type             = var.lb_listner_default_action
        target_group_arn = var.lb_target_group_arn
    }
}






            