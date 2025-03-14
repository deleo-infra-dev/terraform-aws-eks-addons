################################################################################
# EFS-CSI-Driver
################################################################################
# https://github.com/aws-ia/terraform-aws-eks-blueprints/blob/v3.5.2/examples/aws-efs-csi-driver/main.tf


################################################################################
# [ Random String ] #
################################################################################
resource "random_string" "suffix" {
  length  = 8
  special = false
}

################################################################################
# [ aws_efs_file_system ] # 
################################################################################
resource "aws_efs_file_system" "efs" {
  creation_token = random_string.suffix.result 
  encrypted      = true
}

################################################################################
# [ aws_security_group ] #  - Allow inbound NFS traffic from private subnets of the VPC
## - Allow inbound NFS traffic from private subnets of the VPC
################################################################################
resource "aws_security_group" "efs_sg" {
  name        = "efs-sg"
  description = "Allow inbound NFS traffic from private subnets of the VPC"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [var.eks_private_cidr]
  }

  tags = try(var.aws_efs_csi_driver.tags, {})
}

################################################################################
# [ aws_efs_mount_target ] #  - Mount target for the EFS file system
################################################################################
resource "aws_efs_mount_target" "efs_mt" {
  for_each        = toset(slice(var.private_subnet_ids, 0, 3))
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = each.value
  security_groups = [aws_security_group.efs_sg.id]
}

################################################################################
# [ kubectl_manifest ] #  - Storage class for the EFS file system
################################################################################
resource "kubectl_manifest" "efs_storage_class" {
  yaml_body = <<-YAML
    apiVersion: storage.k8s.io/v1
    kind: StorageClass
    metadata:
      name: efs
    provisioner: efs.csi.aws.com
    parameters:
      provisioningMode: efs-ap
      fileSystemId: ${aws_efs_file_system.efs.id}
      directoryPerms: "700"
  YAML
}