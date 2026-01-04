variable "db_subnet_group_name" {}
variable "subnet_groups" {}
variable "mysql_db_identifier" {}
variable "mysql_username" {}
variable "mysql_password" {}
variable "rds_mysql_sg_id" {}
variable "mysql_dbname" {}

output "rds_hostname" {
  value = aws_db_instance.default.address
}


# RDS Subnet Group
resource "aws_db_subnet_group" "srl_proj_dev_db_subnet_group" {
  name       = var.db_subnet_group_name
  subnet_ids = var.subnet_groups                      # replace with your private subnet IDs
}

resource "aws_db_instance" "default" {
    allocated_storage       = 20
    storage_type            = "gp2"
    engine                  = "mysql"
    engine_version          = "8.0"
    instance_class          = "db.t3.micro"
    identifier              = var.mysql_db_identifier   #name for DB instance
    username                = var.mysql_username
    password                = var.mysql_password

    vpc_security_group_ids  = [var.rds_mysql_sg_id]
    db_subnet_group_name    = aws_db_subnet_group.srl_proj_dev_db_subnet_group.name
    db_name                 = var.mysql_dbname
    skip_final_snapshot     = true                     #its only related to deletion,do NOT take a final snapshot
    apply_immediately       = true
    backup_retention_period = 0                        #if 7 automatically deletes backups older than 7 days
    deletion_protection     = false
    multi_az                = false                    # if true: Create 1 primary + 1 standby (different AZ), If primary fails:automatically switches to standby.(Downtime 1-2 min)
    storage_encrypted       = true                     #if true: Encrypt that 20 GB gp2 EBS volume, Encrypt backups & snapshots taken from it, Encrypt all data written to it (tables, indexes, logs)
    publicly_accessible     = false                    #if dont put here with false: AWS uses its default behavior, which depends on where your DB subnet group lives
    }