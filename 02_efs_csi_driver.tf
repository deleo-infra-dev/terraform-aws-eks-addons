################################################################################
# Random String for EFS File System Name
# - 랜덤 문자열 생성
################################################################################
resource "random_string" "suffix" {
  length  = 8  # 8자리 랜덤 문자열 생성
  special = false  # 특수문자 사용 안함
  upper   = false  # 대문자 사용 안함
}

################################################################################
# EFS File System
# - https://aws.github.io/aws-eks-best-practices/storage/efs/#create-an-efs-file-system
################################################################################
resource "aws_efs_file_system" "efs" {
  creation_token = "eks-efs-${var.cluster_name}-${random_string.suffix.result}"
  encrypted      = true
  performance_mode = "generalPurpose"  # 대부분의 워크로드에 적합
  throughput_mode = "bursting"  # 비용 효율적인 설정

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"  # 30일 후 IA 스토리지로 전환하여 비용 절감
  }

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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
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
  for_each        = toset(slice(var.private_subnet_ids, 0, length(var.private_subnet_ids) > 3 ? 3 : length(var.private_subnet_ids)))
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = each.value
  security_groups = [aws_security_group.efs_sg.id]
}

################################################################################
# EFS StorageClass 생성
## (마운트 타겟이 준비된 후 스토리지 클래스 생성)
################################################################################
resource "kubectl_manifest" "efs_storage_class" {
  depends_on = [aws_efs_mount_target.efs_mt]  # 모든 마운트 타겟이 준비될 때까지 대기
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