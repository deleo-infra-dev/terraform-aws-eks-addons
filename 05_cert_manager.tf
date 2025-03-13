################################################################################
# Cert-Manager
################################################################################

################################################################################
# [ Local ] #
## - Local variables for the Cert Manager
################################################################################
locals {
  cert_manager_zones                    = var.cert_manager_zones
  cert_manager_route53_hosted_zone_arns = data.aws_route53_zone.cert_manager[*].arn
  cert_manager_iam_role_arn             = module.eks_addons.cert_manager.iam_role_arn
}

################################################################################
# [ Data ] #
## - Data for the Cert Manager
################################################################################
data "aws_route53_zone" "cert_manager" {
  count = length(local.cert_manager_zones)
  name  = element(local.cert_manager_zones, count.index)
}

################################################################################
# [ kubectl_manifest ] #
## - Cluster Issuer
################################################################################  
resource "kubectl_manifest" "prod_cluster_issuer" {
  yaml_body = <<-YAML
    apiVersion: cert-manager.io/v1
    kind: ClusterIssuer
    metadata:
      name: letsencrypt-prod
    spec:
      acme:
        email: ${var.acme_email}
        server: https://acme-v02.api.letsencrypt.org/directory
        privateKeySecretRef:
          name: letsencrypt-prod
        solvers:
        - dns01:
            cnameStrategy: Follow
            route53:
              region: ap-northeast-2
  YAML

  depends_on = [
    module.eks_addons
  ]
}