################################################################################
# Cert-Manager
################################################################################

locals {
  cert_manager_zones = var.cert_manager_zones
  cert_manager_route53_hosted_zone_arns = data.aws_route53_zone.cert_manager[*].arn
  cert_manager_iam_role_arn = "${module.eks_addons.cert_manager.iam_role_arn}"
}

data "aws_route53_zone" "cert_manager" {
  count = length(local.cert_manager_zones)
  name = element(local.cert_manager_zones, count.index)
}

resource "kubectl_manifest" "aws_prod_cluster_issuer" {
  count = var.create_aws_cluster_issuer ? 1 : 0

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
              region: ${var.region}
  YAML
}