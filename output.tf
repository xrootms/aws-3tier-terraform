output "ssh_connection_string_for-app_ec2" {
  value = "ssh -i ~/Documents/keys/devops_proj1 ubuntu@${module.ec2.app_ec2_instance_public_ip}"
}