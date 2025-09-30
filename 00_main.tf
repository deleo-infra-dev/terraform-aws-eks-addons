################################################################################
# EKS Addons
################################################################################

module "eks_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.0"

  cluster_name      = var.cluster_name
  cluster_endpoint  = var.cluster_endpoint
  cluster_version   = var.cluster_version
  oidc_provider_arn = var.oidc_provider_arn

  eks_addons = {
    aws-ebs-csi-driver = {
      addon_version            = try(var.aws_ebs_csi_driver.addon_version, "v1.20.0-eksbuild.1")
      service_account_role_arn = module.irsa-ebs-csi.iam_role_arn
    }
  }
  enable_aws_load_balancer_controller = true
  aws_load_balancer_controller = {
    chart_version = try(var.aws_load_balancer_controller.chart_version, "1.7.1")
    set = concat([
      {
        name = "enableServiceMutatorWebhook"
        value = "false"
      }
    ],
    try(var.aws_load_balancer_controller.set, [])
    )
  }
  enable_aws_efs_csi_driver = true
  enable_external_secrets = true
  enable_external_dns = true
  external_dns_route53_zone_arns = local.external_dns_route53_zone_arns
  external_dns = {
    chart_version = try(var.external_dns.chart_version, "1.14.3")
    set = concat([
      {
        name = "policy"
        value = "${var.external_dns_policy}"
      },
      {
        name = "domainFilters"
        value = "{${local.external_dns_domain_filters}}"
      }
    ],
    try(var.external_dns.set, [])
    )
  }
  external_secrets = {
    service_account_name = "${local.es_service_account_name}"
  }
  enable_cert_manager = true
  cert_manager_route53_hosted_zone_arns = local.cert_manager_route53_hosted_zone_arns
  cert_manager = {set = try(var.cert_manager.set, [])}

  tags = var.tags
}