output "ec2_bastion_public_ip" {
  value = aws_eip.bastion_eip.public_ip
}

output "bastion_instance_id" {
  value = module.ec2_public.id
}

output "bastion_sg_id" {
  value = module.public_bastion_sg.security_group_id
}