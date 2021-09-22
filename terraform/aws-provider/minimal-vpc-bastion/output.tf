output "bastion_connect_string" {
  value = "ssh -i ~/.ssh/bastion-${var.global_name}-key-pair.pem -p 22 ec2-user@${module.bastion.bastion_public_ip}"
}
