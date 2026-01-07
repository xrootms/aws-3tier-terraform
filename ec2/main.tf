variable "ami_id" {}
variable "instance_type" {}
variable "iam_instance_profile" {}
variable "ec2_tag_name" {}
variable "key_name" {}
variable "subnet_id" {}
variable "sg_for_ec2" {}
variable "enable_public_ip_address" {}
variable "user_data_install_app" {}

output "app_ec2_instance_id" {
  value = aws_instance.srl_proj_dev_ec2.id
}

output "app_ec2_instance_public_ip" {
  value = aws_instance.srl_proj_dev_ec2.public_ip
}

resource "aws_instance" "srl_proj_dev_ec2" {
    ami = var.ami_id
    instance_type = var.instance_type
    iam_instance_profile   = var.iam_instance_profile
    tags = { Name = var.ec2_tag_name }

    key_name                    = var.key_name
    subnet_id                   = var.subnet_id
    vpc_security_group_ids      = var.sg_for_ec2
    associate_public_ip_address = var.enable_public_ip_address
    user_data = var.user_data_install_app

    metadata_options {
    http_endpoint = "enabled"  # Enable the IMDSv2 endpoint
    http_tokens   = "required" # Require the use of IMDSv2 tokens
  }
}
