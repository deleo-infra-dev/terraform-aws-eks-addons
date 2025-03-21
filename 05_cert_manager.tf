################################################################################
# Cert-Manager
################################################################################

locals {
  cert_manager_zones = var.cert_manager_zones
  cert_manager_route53_hosted_zone_arns = data.aws_route53_zone.cert_manager[*].arn
}

################################################################################
# Route53 영역 데이터 소스
################################################################################
data "aws_route53_zone" "cert_manager" {
  count = length(local.cert_manager_zones)
  name  = element(local.cert_manager_zones, count.index)
}

################################################################################
# ClusterIssuer 생성 (Let's Encrypt)
################################################################################

resource "helm_release" "cluster_issuer" {
  count = var.create_aws_cluster_issuer ? 1 : 0

  name       = "cluster-issuer"
  namespace  = "cert-manager"
  repository = "https://bedag.github.io/helm-charts/"
  chart      = "raw"
  version    = "2.0.0"

  values = [
    <<-EOF
    resources:
    - apiVersion: cert-manager.io/v1
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
                hostedZoneID: ${length(data.aws_route53_zone.cert_manager) > 0 ? data.aws_route53_zone.cert_manager[0].zone_id : ""}
    EOF
  ]

  # module.eks_addons가 완료될 때까지 대기
  depends_on = [
    module.eks_addons
  ]
}