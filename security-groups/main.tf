
variable "ec2_sg_name" {}
variable "vpc_id" {}
variable "sg_ssh_http_ports" { default = [22, 80, 443] }
variable "ec2_sg_name_for_python_api" {}

output "sg_ec2_sg_ssh_http_id" {
  value = aws_security_group.ec2_sg_ssh_http.id
}

output "rds_mysql_sg_id" {
  value = aws_security_group.rds_mysql_sg.id
}

output "sg_ec2_for_python_api" {
  value = aws_security_group.ec2_sg_python_api.id
}


#----SG for ports: 22, 80, 443----
resource "aws_security_group" "ec2_sg_ssh_http" {
  name        = var.ec2_sg_name
  vpc_id      = var.vpc_id
  description = "Enable the Port 22, 80, 443"

  #Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow outgoing request to anywhere"
  }
  tags = { Name = "Security Group: SSH, HTTP, HTTPS" }
}

#Ingress rules using count
resource "aws_security_group_rule" "sg_ingress_ssh_http" {
  count             = length(var.sg_ssh_http_ports)
  type              = "ingress"
  from_port         = var.sg_ssh_http_ports[count.index]
  to_port           = var.sg_ssh_http_ports[count.index]
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ec2_sg_ssh_http.id
  description       = "Allow port ${var.sg_ssh_http_ports[count.index]} from anywhere"
}

# Security Group for app
resource "aws_security_group" "ec2_sg_python_api" {
  name        = var.ec2_sg_name_for_python_api
  vpc_id      = var.vpc_id
  description = "Enable the Port 5000 for python api"

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow traffic on port 5000"
  }
  tags = { Name = "Security Group: 5000" }
}

# Security Group for RDS
resource "aws_security_group" "rds_mysql_sg" {
  name        = "SG for RDS to enable port 3306"
  vpc_id      = var.vpc_id
  description = "Allow access to RDS from EC2 present in public subnet"

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg_python_api.id] #Only traffic coming from EC2 instances that have SG-Python-API attached can reach DB on port 3306.
    description     = "Allow MySQL from EC2 SG"
  }
  tags = { Name = "Security Group: 3360" }
}
