################################################################################
# Outputs
################################################################################

output "gp3_default_command" {
  description = "gp2 스토리지 클래스의 기본값 주석을 제거하는 명령어"
  value       = "kubectl annotate sc gp2 storageclass.kubernetes.io/is-default-class-"
}

output "eks_addons_module" {
  description = "EKS 애드온 모듈 정보"
  value       = module.eks_addons
}

output "efs_file_system_id" {
  description = "EFS 파일 시스템 ID"
  value       = aws_efs_file_system.efs.id
}

output "efs_security_group_id" {
  description = "EFS 보안 그룹 ID"
  value       = aws_security_group.efs_sg.id
}

output "ebs_csi_role_arn" {
  description = "EBS CSI 드라이버 IAM 역할 ARN"
  value       = module.irsa-ebs-csi.iam_role_arn
}