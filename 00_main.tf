################################################################################
# EKS Addons
## computeType = "Standard" (Standard 또는 Performance 사용 가능)
## - EKS 1.30 호환성을 위한 추가 설정 
## - EKS 1.30 이하 사용 시 오류 발생, 참고: https://github.com/aws-ia/terraform-aws-eks-blueprints/issues/1500)
################################################################################

module "eks_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.20"

  cluster_name      = var.cluster_name
  cluster_endpoint  = var.cluster_endpoint
  cluster_version   = var.cluster_version
  oidc_provider_arn = var.oidc_provider_arn

  eks_addons = {
    ## coreDNS ##
    coredns = {
      most_recent = true
      configuration_values = jsonencode({
        resources = {
          limits = {
            cpu    = "0.25"
            memory = "512M"
          }
          requests = {
            cpu    = "0.25"
            memory = "512M"
          }
        }

        computeType = "Standard" 
      })
    }

    ## [vpc-cni] ##
    vpc-cni = {
      most_recent = true

      configuration_values = jsonencode({
        env = {
          ENABLE_PREFIX_DELEGATION = "true" # IP 주소 효율적 사용을 위한 설정
          WARM_ENI_TARGET = "1"
          WARM_IP_TARGET = "5"
        }
      })
    }

    ## [kube-proxy] ##
    kube-proxy = {
      most_recent = true
    }

    ## [aws-ebs-csi-driver] ##
    aws-ebs-csi-driver = {
      most_recent = true
      service_account_role_arn = module.irsa-ebs-csi.iam_role_arn
    }
  }

  ## [ aws_load_balancer_controller ] ##
  enable_aws_load_balancer_controller = true
  aws_load_balancer_controller = {
    most_recent = true
    set = [
      {
        name  = "enableServiceMutatorWebhook"
        value = "false"
      }
    ]
  }

  ## [ aws_efs_csi_driver ] ##
  enable_aws_efs_csi_driver = true

  ## [ external_secrets ##
  enable_external_secrets = true

  ## [ external_dns ] ##
  enable_external_dns = true
  external_dns_route53_zone_arns = local.external_dns_route53_zone_arns
  external_dns = {
    set = concat([
      {
        name  = "policy"
        value = var.external_dns_policy
      },
      {
        name  = "domainFilters"
        value = "{${local.external_dns_domain_filters}}"
      }
    ],
      try(var.external_dns.set, [])
    )
  }

  ## [ external_secrets ] ##
  external_secrets = {
    namespace = "external-secrets"
    service_account_name = local.es_service_account_name
  }

  ## [ cert_manager ] ##
  enable_cert_manager = true
  cert_manager_route53_hosted_zone_arns = local.cert_manager_route53_hosted_zone_arns
  cert_manager = {
    set = try(var.cert_manager.set, [])
    namespace = "cert-manager"
  }

  ## [ tags ] ##
  tags = var.tags
}