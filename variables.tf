################################################################################
# AWS Region
################################################################################
variable "region" {
  description = "AWS 리전"
  type        = string
}

################################################################################
# VPC
################################################################################
variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "프라이빗 서브넷 ID 목록"
  type        = list(string)
}

variable "eks_private_cidr" {
  description = "EKS 프라이빗 서브넷 CIDR 블록"
  type        = string
}

################################################################################
# EKS Cluster
################################################################################
variable "cluster_name" {
  description = "EKS 클러스터 이름"
  type        = string
}

variable "cluster_endpoint" {
  description = "Kubernetes API 서버 엔드포인트"
  type        = string
}

variable "cluster_version" {
  description = "EKS 클러스터 Kubernetes 버전 (예: '1.30')"
  type        = string
}

variable "cluster_ca_certificate" {
  description = "EKS 클러스터 CA 인증서"
  type        = string
}

################################################################################
# OIDC Provider
################################################################################
variable "oidc_provider_arn" {
  description = "클러스터 OIDC 제공자 ARN"
  type        = string
}

variable "oidc_provider" {
  description = "OpenID Connect 제공자 URL"
  type        = string
}

################################################################################
# External DNS
################################################################################
variable "external_dns_policy" {
  description = "External-DNS 정책 (upsert-only, sync, create-only)"
  type        = string
  default     = "upsert-only"
}

variable "external_dns_zones" {
  description = "External-DNS 영역 목록"
  type = list(object({
    name    = string
    hosting = bool
  }))
  default = []
}

variable "external_dns" {
  description = "External-DNS 애드온 구성 값"
  type        = any
  default     = {}
}

################################################################################
# Cert Manager
################################################################################
variable "cert_manager_zones" {
  description = "Cert-Manager 영역 목록"
  type        = list(string)
  default     = []
}

variable "cert_manager" {
  description = "Cert-Manager 애드온 구성 값"
  type        = map(any)
  default     = {}
}

variable "acme_email" {
  description = "Let's Encrypt ACME에 등록할 이메일"
  type        = string
  default     = "noreply@example.com"
}

variable "create_aws_cluster_issuer" {
  description = "AWS ClusterIssuer 생성 여부"
  type        = bool
  default     = false
}

################################################################################
# CSI Driver
################################################################################
variable "aws_efs_csi_driver" {
  description = "EFS CSI 드라이버 애드온 구성 값"
  type        = any
  default     = {}
}

variable "aws_ebs_csi_driver" {
  description = "EBS CSI 드라이버 애드온 구성 값"
  type        = any
  default     = {}
}

################################################################################
# TAG
################################################################################
variable "tags" {
  description = "모든 리소스에 추가할 태그 맵"
  type        = map(string)
  default     = {}
}