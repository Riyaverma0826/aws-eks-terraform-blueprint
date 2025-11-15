data "aws_ami" "amzlinux2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.amzlinux2.id
  instance_type               = var.instance_type
  key_name                    = var.instance_keypair
  subnet_id                   = var.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.public_bastion_sg.id]
  associate_public_ip_address = true
  monitoring                  = true

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-bastion"
    }
  )
}


resource "aws_eip" "bastion_eip" {
  depends_on = [aws_instance.bastion]
  instance   = aws_instance.bastion.id
  domain     = "vpc"

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-bastion-eip"
    }
  )
}

