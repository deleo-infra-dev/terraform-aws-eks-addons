variable "region" {
  description = "Region"
  type        = string
  default     = ""
}
variable "vpc_id" {
  description = "vpc id"
  type        = string
  default     = ""
}
variable "private_subnet_ids" {
  type        = list(string)
  description = "프라이빗 서브넷 ID 목록"
}
variable "eks_private_cidr" {
  description = "CIDR block for EKS private subnets"
  type        = string
}
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  type        = string
}
variable "cluster_version" {
  description = "Kubernetes `<major>.<minor>` version to use for the EKS cluster (i.e.: `1.24`)"
  type        = string
}
variable "oidc_provider_arn" {
  description = "The ARN of the cluster OIDC Provider"
  type        = string
}
variable "oidc_provider" {
  description = "OpenID Connect provider URL"
  type        = string
}
variable "cluster_ca_certificate" {
  type        = string
  description = "EKS 클러스터 CA 인증서"
}
variable "external_dns_policy" {
  description = "external-dns policy"
  type        = string
  default     = "upsert-only"
}
variable "external_dns_zones" {
  description = "external-dns zone list"
  type        = list(any)
  default     = []
}
variable "external_dns" {
  description = "external-dns add-on configuration values"
  type        = any
  default     = {}
}
variable "cert_manager_zones" {
  description = "cert-manager zone list"
  type        = list(string)
  default     = []
}
variable "cert_manager" {
  description = "cert_manager add-on configuration values"
  type        = map(any)  # 객체 타입으로 선언
  default     = {}
}
variable "acme_email" {
  description = "email register on lentsencrypt acme"
  type        = string
  default     = "noreply@example.com"
}
variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "aws_efs_csi_driver" {
  description = "EFS CSI Driver add-on configuration values"
  type        = any
  default     = {}
}

variable "aws_ebs_csi_driver" {
  description = "EBS CSI Driver add-on configuration values"
  type        = any
  default     = {}
}
variable "create_aws_cluster_issuer" {
  description = "create aws cluster issuer"
  type        = bool
  default     = false
}

