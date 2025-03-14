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
    ## coreDNS ##
    coredns = {
      most_recent = true # 최신 버전 사용 권장
      replicas    = 2    # (Optional) The number of replicas for the CoreDNS addon.
      configuration_values = jsonencode({
        resources = {
          limits = {
            cpu    = "0.25" # (Optional) The CPU limit for the CoreDNS addon.
            memory = "512M" # (Optional) The memory limit for the CoreDNS addon.
          }
          requests = {
            cpu    = "0.25" # (Optional) The CPU request for the CoreDNS addon.
            memory = "512M" # (Optional) The memory limit for the CoreDNS addon.
          }
        }
      })
    }
     ## [vpc-cni] ##
    vpc-cni = {
      most_recent = "true"
    } # end of vpc-cni section

    ## [kube-proxy] ##
    kube-proxy = {
      most_recent = "true"
    } # end of kube-proxy section
    aws-ebs-csi-driver = {
      addon_version            = try(var.aws_ebs_csi_driver.addon_version, "v1.20.0-eksbuild.1")

      service_account_role_arn = module.irsa-ebs-csi.iam_role_arn
    }
  }
  enable_aws_load_balancer_controller = "true"
  aws_load_balancer_controller = {
    most_recent = "true" # 최신 버전 사용 권장  
    set = [
      {
        name = "enableServiceMutatorWebhook"
        value = "false"
      }
    ]
  }
  enable_aws_efs_csi_driver = "true"
  
  enable_external_secrets = "true"
  enable_external_dns = "true"
  external_dns_route53_zone_arns = local.external_dns_route53_zone_arns
  external_dns = {
    set = concat([
      {
        name = "policy"
        value = var.external_dns_policy
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
  enable_cert_manager = "true"
  cert_manager_route53_hosted_zone_arns = local.cert_manager_route53_hosted_zone_arns
  cert_manager = {set = try(var.cert_manager.set, [])}

  tags = var.tags
}