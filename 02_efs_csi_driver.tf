################################################################################
# Random String for EFS File System Name
# - 랜덤 문자열 생성
################################################################################
resource "random_string" "suffix" {
  length  = 8 # 8자리 랜덤 문자열 생성
  special = false # 특수문자 사용 안함
  upper   = false # 대문자 사용 안함
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
# EFS StorageClass 삭제
# - 기존 StorageClass가 있는 경우 삭제
################################################################################
# 기존 EFS StorageClass 삭제
# --ignore-not-found: StorageClass가 없는 경우에도 에러가 발생하지 않도록 함
resource "null_resource" "delete_existing_storage_class" {
  provisioner "local-exec" {
    command = "kubectl delete sc efs --ignore-not-found"
  }
}

################################################################################
# EFS StorageClass 생성
# - provisioner: AWS EFS CSI 드라이버 사용
# - parameters:
#   - provisioningMode: efs-ap (access point 모드)
#   - fileSystemId: EFS 파일시스템 ID
#   - directoryPerms: EFS 디렉토리 권한 (700: 소유자만 읽기/쓰기/실행 가능)
################################################################################

resource "kubectl_manifest" "efs_storage_class" {
  depends_on = [null_resource.delete_existing_storage_class]
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