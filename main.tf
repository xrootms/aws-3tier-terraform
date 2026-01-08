module "networking" {
  source               = "./networking"
  vpc_cidr             = var.vpc_cidr
  vpc_name             = var.vpc_name
  cidr_public_subnet   = var.cidr_public_subnet
  ap_availability_zone = var.ap_availability_zone
  cidr_private_subnet  = var.cidr_private_subnet
}

module "security_group" {
  source                     = "./security-groups"
  ec2_sg_name                = "SG for EC2 to enable SSH(22), HTTP(80) and HTTPS(443)"
  vpc_id                     = module.networking.srl_proj_dev_vpc_id
  ec2_sg_name_for_python_api = "SG for EC2 for enabling port 5000"
}


module "ec2" {
  source                   = "./ec2"
  ami_id                   = var.ec2_ami_id
  instance_type            = "t2.micro"
  iam_instance_profile     = module.iam_ec2_s3.instance_profile_name
  ec2_tag_name             = "Srl-Proj-Dev-Flask-App-EC2"
  subnet_id                = tolist(module.networking.srl_proj_dev_public_subnets)[0]
  sg_for_ec2               = [module.security_group.sg_ec2_sg_ssh_http_id, module.security_group.sg_ec2_for_python_api]
  enable_public_ip_address = true
  user_data_install_app    = templatefile("./template/ec2_install_app.sh", {rds_endpoint = module.rds.rds_hostname})
  key_name                 = aws_key_pair.main_key.key_name
  depends_on               = [module.rds]
}

module "lb_target_group" {
  source                   = "./load-balancer-target-group"
  lb_target_group_name     = "srl-proj-dev-lb-target-group"
  lb_target_group_port     = 5000
  lb_target_group_protocol = "HTTP"
  vpc_id                   = module.networking.srl_proj_dev_vpc_id
  ec2_instance_id          = module.ec2.app_ec2_instance_id
}

module "alb" {
  source                    = "./load-balancer"
  lb_name                   = "srl-proj-dev-alb"
  is_external               = false
  lb_type                   = "application"
  sg_enable_ssh_https       = module.security_group.sg_ec2_sg_ssh_http_id
  subnet_ids                = tolist(module.networking.srl_proj_dev_public_subnets)
  tag_name                  = "srl-proj-dev-alb"
  lb_target_group_arn       = module.lb_target_group.srl_proj_dev_lb_target_group_arn
  ec2_instance_id           = module.ec2.app_ec2_instance_id
  lb_target_group_attachment_port = 5000
  lb_http_listner_port       = 80
  lb_http_listner_protocol   = "HTTP"
  lb_listner_default_action  = "forward"
  lb_https_listner_port     = 443
  lb_https_listner_protocol = "HTTPS"
  srl_proj_dev_acm_arn      = module.aws_ceritification_manager.srl_proj_dev_acm_arn
}

module "hosted_zone" {
  source          = "./hosted-zone"
  domain_name     = var.domain_name
  aws_lb_dns_name = module.alb.aws_lb_dns_name
  aws_lb_zone_id  = module.alb.aws_lb_zone_id
}

module "aws_ceritification_manager" {
  source         = "./certificate-manager"
  domain_name    = var.domain_name
  hosted_zone_id = module.hosted_zone.hosted_zone_id
}

module "rds" {
  source               = "./rds"
  db_subnet_group_name = "srl_proj_dev_rds_subnet_group"
  subnet_groups        = tolist(module.networking.srl_proj_dev_private_subnets)
  rds_mysql_sg_id      = module.security_group.rds_mysql_sg_id
  mysql_db_identifier  = "mydb"
  mysql_username       = "dbuser"
  mysql_password       = "dbpassword"
  mysql_dbname         = "employee"
}


module "s3" {
  source      = "./s3"
  bucket_name = var.bucket_name
  s3_tag_name     = "Srl-Proj_Dev-image-S3-Bucket"
}

module "iam_ec2_s3" {
  source     = "./iam-ec2-s3"
  role_name  = "srl-proj-dev-ec2-s3-access-role"
  bucket_arn = module.s3.bucket_arn
}

