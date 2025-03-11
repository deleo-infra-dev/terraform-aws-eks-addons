################################################################################
# EKS Addons 
## - (https://github.com/aws-ia/terraform-aws-eks-blueprints/tree/main/modules/addons)
################################################################################
module "eks_addons" {

  ## Module ##
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.0" # (Required) The version of the module to use.

  ## EKS Cluster ##
  cluster_name      = var.cluster_name      # (Required) The name of the EKS cluster.
  cluster_endpoint  = var.cluster_endpoint  # (Required) The endpoint of the EKS cluster.
  cluster_version   = var.cluster_version   # (Required) The Kubernetes version of the EKS cluster.
  oidc_provider_arn = var.oidc_provider_arn # (Required) The ARN of the OIDC provider.


  ## [[ 1️⃣ EKS Addons ]] ##
  eks_addons = {

    ## CoreDNS ##
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

    ## VPC CNI ##
    vpc-cni = {}

    ## kube-proxy ##
    kube-proxy = {}

    ## AWS EBS CSI Driver ##
    enable_aws_ebs_csi_driver = true
    aws-ebs-csi-driver = {
      most_recent              = true
      service_account_role_arn = module.irsa-ebs-csi.iam_role_arn
    }

    ## AWS EFS CSI Driver ##
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

    ## External Secrets ##
    external_secrets = {
    service_account_name = "${local.es_service_account_name}"
  }
  

    ## External DNS ##
    enable_external_dns            = true
    external_dns_route53_zone_arns = local.external_dns_route53_zone_arns # (Optional) A list of Route53 zone ARNs to use for the external DNS addon.
    external_dns = {
      set = concat(
        try(var.external_dns.set, []),
        [
          {
            name  = "policy"
            value = "${var.external_dns_policy}"
          },
          {
            name  = "domainFilters"
            value = "{${local.external_dns_domain_filters}}"
          }
        ]
      )
    }

    ## Cert Manager ##
    enable_cert_manager                   = true
    cert_manager_route53_hosted_zone_arns = local.cert_manager_route53_hosted_zone_arns
    cert_manager                          = { set = try(var.cert_manager.set, []) }

    ## Tags ##
    tags = var.tags

  }
}

# // Ensure the region variable is passed to the external secrets configuration
# resource "kubectl_manifest" "cluster_secretstore" {
#   yaml_body = templatefile("${path.module}/cluster_secretstore.yaml.tpl", {
#     name                = "default"
#     region              = var.region
#     service_account_name = local.es_service_account_name
#   })

#   depends_on = [
#     module.eks_addons
#   ]
# }
