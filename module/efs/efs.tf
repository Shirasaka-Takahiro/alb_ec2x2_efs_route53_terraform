##EFS
resource "aws_efs_file_system" "efs" {
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  encrypted        = true
  lifecycle_policy {
    transition_to_ia = "AFTER_7_DAYS"
  }

  tags = {
    Name = "${var.general_config["project"]}-${var.general_config["env"]}-efs"
    Tag  = "${var.general_config["project"]}-${var.general_config["env"]}-efs"
  }
}

##Backup policy
resource "aws_efs_backup_policy" "policy" {
  file_system_id = aws_efs_file_system.efs.id

  backup_policy {
    status = var.efs_backup_policy
  }
}

##Mount targets
resource "aws_efs_mount_target" "efs-mount" {
  file_system_id  = aws_efs_file_system.efs.id
  count           = length(var.public_subnet_ids)
  subnet_id       = element(var.public_subnet_ids, count.index % 2)
  security_groups = [var.efs_sg_id]
}

# Amazon EFS file system policy
resource "aws_efs_file_system_policy" "efa_policy" {
  file_system_id = aws_efs_file_system.efs.id
  policy         = <<-EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": ["elasticfilesystem:ClientMount"],
          "Principal": {
            "AWS": "*"
          }
        }
      ]
    }
  EOF
}