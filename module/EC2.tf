##Web Instance
resource "aws_instance" "ec2-web" {
  ami       = var.ami
  count = length(var.public_subnets.subnets)
  subnet_id = element(values(aws_subnet.public_subnets)[*].id, count.index % 2)
  vpc_security_group_ids = [
    aws_security_group.common.id,
    aws_security_group.ec2.id
  ]
  key_name      = aws_key_pair.key.id
  instance_type = var.instance_type
  root_block_device {
    volume_type = var.volume_type
    volume_size = var.volume_size
  }

  user_data = <<EOF
  #!/bin/bash
  yum -y install amazon-efs-utils
  mkdir /mnt/share
  mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2s ${aws_efs_file_system.efs_file_system.id}.efs.ap-northeast-1.amazonaws.com:/ /mnt/share
  echo ${aws_efs_file_system.efs_file_system.dns_name}:/ /mnt/share efs defaults,_netdev 0 0 >> /etc/fstab
  mount -a
  EOF

  tags = {
    Name = "${var.general_config["project"]}-${var.general_config["env"]}-${format("web%02d", count.index + 1)}"
  }
}

##DB Instance
resource "aws_instance" "ec2-db" {
  ami       = var.ami
  subnet_id = var.private_subnet_ids[0]
  vpc_security_group_ids = [
    aws_security_group.common.id,
  ]
  key_name      = aws_key_pair.key.id
  instance_type = var.instance_type
  root_block_device {
    volume_type = var.volume_type
    volume_size = var.volume_size
  }

  tags = {
    Name = "${var.general_config["project"]}-${var.general_config["env"]}-db01"
  }
}

##Elastic IP
resource "aws_eip" "eip_ec2" {
  vpc      = true
  count = length(aws_instance.ec2-web)
  instance = element(aws_instance.ec2-web.*.id, count.index % 2)

  tags = {
    Name = "${var.general_config["project"]}-${var.general_config["env"]}-${format("eip%02d", count.index + 1)}"
  }
}

##Key Pair
resource "aws_key_pair" "key" {
  key_name   = var.key_name
  public_key = "${file(var.public_key_path)}"
}