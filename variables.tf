variable "region" {
  description = "Region"
  type        = any
  default     = {}
}
variable "vpc_id" {
  description = "vpc id"
  type        = any
  default     = {}
}
variable "private_subnet_ids" {
  description = "vpc private subnet ids"
  type        = any
  default     = {}
}
variable "eks_private_cidr" {
  description = "eks private cidr"
  type        = any
  default     = {}
}
variable "cluster_name" {
  description = "cluster name"
  type        = any
  default     = {}
}
variable "cluster_endpoint" {
  description = "cluster endpoint"
  type        = any
  default     = {}
}
variable "cluster_version" {
  description = "cluster version"
  type        = any
  default     = {}
}
variable "oidc_provider_arn" {
  description = "oidc provider arn"
  type        = any
  default     = {}
}
variable "oidc_provider" {
  description = "oidc provider"
  type        = any
  default     = {}
}
variable "cluster_ca_certificate" {
  description = "cluster ca certificate"
  type        = any
  default     = {}
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
  type        = any
  default     = {}
}
variable "acme_email" {
  description = "email register on lentsencrypt acme"
  type        = string
  default     = "noreply@example.com"
}
variable "tags" {
  description = "tags"
  type        = any
  default     = {}
}
variable "aws_ebs_csi_driver" {
  description = "aws ebs csi driver override variables"
  type        = any
  default     = {}
}
variable "aws_efs_csi_driver" {
  description = "aws efs csi driver override variables"
  type        = any
  default     = {}
}