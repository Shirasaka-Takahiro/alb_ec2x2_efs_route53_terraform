##File System
resource "aws_efs_file_system" "efs_file_system" {
  encrypted = "true"

  tags = {
    Name = "${var.general_config["project"]}-${var.general_config["env"]}-efs-filesystem"
  }
}

##Mount Target
resource "aws_efs_mount_target" "efs_mount_target" {
  count = length(var.public_subnets.subnets)
  subnet_id = element(values(aws_subnet.public_subnets)[*].id, count.index % 2)
  file_system_id = aws_efs_file_system.efs_file_system.id
  security_groups = [aws_security_group.efs.id]
}