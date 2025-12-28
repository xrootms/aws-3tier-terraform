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
  ec2_sg_name                = "SG for EC2 to enable SSH(22) and HTTP(80)"
  vpc_id                     = module.networking.srl_proj_dev_vpc_id
  ec2_sg_name_for_python_api = "SG for EC2 for enabling port 5000"
}


module "ec2" {
  source                   = "./ec2"
  ami_id                   = var.ec2_ami_id
  instance_type            = "t2.micro"
  ec2_tag_name             = "Ubuntu Linux EC2"
  subnet_id                = tolist(module.networking.srl_proj_dev_public_subnets)[0]
  sg_for_ec2               = [module.security_group.sg_ec2_sg_ssh_http_id, module.security_group.sg_ec2_for_python_api]
  enable_public_ip_address = true
  user_data_install_app    = templatefile("./template/ec2_install_app.sh", {})
  key_name                  = aws_key_pair.main_key.key_name
}