locals {
  ubuntu  = length(regexall("ubuntu", var.name)) > 0
  windows = length(regexall("windows", var.name)) > 0
}

provider "aws" {

}

terraform {
  backend "s3" {
    bucket = "terraform-win-vms"
    key    = "terraform.tfstate"
    region = "eu-central-1"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  owners = ["099720109477"]
}

data "aws_ami" "windows" {
  most_recent = true
  filter {
    name   = "name"
    values = ["Windows_Server-2019-English-Full-Base-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["801119661308"]
}

resource "aws_instance" "ubuntu" {
  count         = local.ubuntu ? 1 : 0
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  key_name      = var.key_name

  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = 100
  }
  vpc_security_group_ids = [aws_security_group.ubuntu[count.index].id]
  tags = {
    Name = var.name
  }
}

resource "aws_instance" "windows_vm" {
  count             = local.windows ? 1 : 0
  ami               = data.aws_ami.windows.id
  instance_type     = var.instance_type
  subnet_id         = var.subnet_id
  key_name          = var.key_name
  get_password_data = "true"

  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = 100
  }

  vpc_security_group_ids = [aws_security_group.windows[count.index].id]
  tags = {
    Name = var.name
  }
}


resource "aws_security_group" "windows" {
  count  = local.windows ? 1 : 0
  vpc_id = var.vpc_id
  name   = var.name

  dynamic "ingress" {
    for_each = var.port_windows
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  #ingress {
  #  from_port   = 3389
  #  protocol    = "TCP"
  #  to_port     = 3389
  #  cidr_blocks = ["0.0.0.0/0"]
  #}
  egress {
    from_port   = 0
    protocol    = "ALL"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = var.name
  }
}

resource "aws_security_group" "ubuntu" {
  count  = local.ubuntu ? 1 : 0
  vpc_id = var.vpc_id
  name   = var.name

  dynamic "ingress" {
    for_each = var.port_ubuntu
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }


  #ingress {
  #  from_port   = 22
  #  protocol    = "TCP"
  #  to_port     = 22
  #  cidr_blocks = ["0.0.0.0/0"]
  #}
  egress {
    from_port   = 0
    protocol    = "ALL"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = var.name
  }
}

resource "aws_eip" "eip_windows" {
  count    = local.windows ? 1 : 0
  instance = aws_instance.windows_vm[count.index].id
  vpc      = true
}

resource "aws_eip" "eip_ubuntu" {
  count    = local.ubuntu ? 1 : 0
  instance = aws_instance.ubuntu[count.index].id
  vpc      = true
}

output "instance_public_ip_win" {
  description = "Public IP address of the EC2 instance"
  value       = aws_eip.eip_windows[*].public_dns
}

output "instance_public_ip_ubuntu" {
  description = "Public IP address of the EC2 instance"
  value       = aws_eip.eip_ubuntu[*].public_dns
}

output "windows_password" {
  #value = [aws_instance.windows_vm[*].password_data] 
  #value = "${rsadecrypt(aws_instance.windows_vm[*].password_data, file("/home/user/local/terr/win-key.pem"))}"
  value = [for g in aws_instance.windows_vm : rsadecrypt(g.password_data, file(var.key_path))]
}

 