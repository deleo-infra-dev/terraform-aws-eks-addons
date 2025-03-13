################################################################################
# EKS Addons
## - (https://github.com/aws-ia/terraform-aws-eks-blueprints/tree/main/modules/addons)
################################################################################
module "eks_addons" {

  ## Module ##
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.0" #ensure to update this to the latest/desired version

  ## EKS Cluster ##
  cluster_name      = var.cluster_name      # (Required) The name of the EKS cluster.
  cluster_endpoint  = var.cluster_endpoint  # (Required) The endpoint of the EKS cluster.
  cluster_version   = var.cluster_version   # (Required) The Kubernetes version of the EKS cluster.
  oidc_provider_arn = var.oidc_provider_arn # (Required) The ARN of the OIDC provider.


  ## [[ EKS Addons ]] ##
  eks_addons = {
    
    enable_aws_ebs_csi_driver = true
    ## aws-ebs-csi-driver ##
    aws-ebs-csi-driver = {
      most_recent              = true
      service_account_role_arn = module.irsa-ebs-csi.iam_role_arn
    }

    ## [ CoreDNS ] ##
    coredns = {
      most_recent = true
      replicas    = 2 # (Optional) The number of replicas for the CoreDNS addon.
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

    ## [aws-load-balancer-controller] ##
    enable_aws_load_balancer_controller = true # (Optional) Whether to enable the aws load balancer controller addon.
    aws-load-balancer-controller = {
      set = [
        {
          name  = "enableServiceMutatorWebhook" # (Optional) Whether to enable the service mutator webhook for the aws load balancer controller addon.
          value = "false" # (Optional) Whether to enable the service mutator webhook for the aws load balancer controller addon.
        }
      ]
    } # end of aws load balancer controller section


    ## [aws-efs-csi-driver] ##
    enable_aws_efs_csi_driver = true
    aws-efs-csi-driver = {
      most_recent              = true
      #service_account_role_arn = module.irsa-efs-csi.iam_role_arn
      repository     = "https://kubernetes-sigs.github.io/aws-efs-csi-driver/"
      chart_version  = "2.4.1"
      aws_efs_csi_driver = {
        role_policies = [
          "arn:aws:iam::aws:policy/AmazonElasticFileSystemFullAccess",
          "arn:aws:iam::aws:policy/AWSKeyManagementServicePowerUser",
          "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
        ]
      }
    }

    ## [External Secrets] ##
    enable_external_secrets = true
    external_secrets = {
      service_account_name = "${local.es_service_account_name}"
    }


    ## External DNS ##
    enable_external_dns = true # (Optional) Whether to enable the external DNS addon.
    external_dns = {
      set = concat([
        {
          name = "policy"
          value = "${var.external_dns_policy}" # (Optional) The policy for the external DNS addon.
        },
        {
          name = "domainFilters"
          value = "{${local.external_dns_domain_filters}}" # (Optional) The domain filters for the external DNS addon.
        }
      ],
      try(var.external_dns.set, [])
      )
    } # end of external dns section 
    external_dns_route53_zone_arns = local.external_dns_route53_zone_arns # (Optional) The Route53 zone ARNs for the external DNS addon.
    

    ## [cert_manager] ##
    enable_cert_manager = true # (Optional) Whether to enable the cert manager addon.
    cert_manager = {
      set = try(
        var.cert_manager.set, []
        ) # (Optional) The set for the cert manager addon.
    } # end of cert manager section
    cert_manager_route53_hosted_zone_arns = local.cert_manager_route53_hosted_zone_arns # (Optional) The Route53 zone ARNs for the cert manager addon.

    ## [vpc-cni] ##
    vpc-cni = {
      most_recent = true
    } # end of vpc-cni section

    ## [kube-proxy] ##
    kube-proxy = {
      most_recent = true
    } # end of kube-proxy section

    ## Tags ##
    tags = var.tags

  }
}

