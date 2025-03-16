################################################################################
# Random String for EFS File System Name
################################################################################
# https://github.com/aws-ia/terraform-aws-eks-blueprints/blob/v3.5.2/examples/aws-efs-csi-driver/main.tf

resource "random_string" "suffix" {
  length  = 8
  special = false # trunk-ignore(checkov/CKV_TF_1)
  upper   = false # trunk-ignore(checkov/CKV_TF_1)
}
################################################################################
# EFS File System
# - https://aws.github.io/aws-eks-best-practices/storage/efs/#create-an-efs-file-system
################################################################################
resource "aws_efs_file_system" "efs" {
  creation_token = "eks-efs-${var.cluster_name}-${random_string.suffix.result}"
  encrypted      = true

  tags = {
    Name = "eks-efs-${var.cluster_name}"
  }
}

################################################################################
# EFS Security Group
# - Allow inbound NFS traffic from private subnets
################################################################################
resource "aws_security_group" "efs_sg" {
  name        = "efs-sg-${var.cluster_name}"
  description = "Allow inbound NFS traffic from private subnets"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [var.eks_private_cidr]
  }

  tags = {
    Name = "eks-efs-sg-${var.cluster_name}"
  }
}

################################################################################
# EFS Mount Target
# - Mount target for the EFS file system
################################################################################
resource "aws_efs_mount_target" "efs_mt" {
  for_each    = toset(slice(var.private_subnet_ids, 0, 3))
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = each.value
  security_groups = [aws_security_group.efs_sg.id]
}

################################################################################
# EFS Storage Class
# - Storage class for the EFS file system
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