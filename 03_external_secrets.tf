################################################################################
# External-Secrets
################################################################################

locals {
  es_service_account_name = "external-secrets-sa"
}

# ClusterSecretStore 정의
resource "helm_release" "cluster_secretstore" {
  name       = "cluster-secretstore"
  namespace  = "external-secrets"
  repository = "https://bedag.github.io/helm-charts/"
  chart      = "raw"
  version    = "2.0.0"

  values = [
    <<-EOF
    resources:
    - apiVersion: external-secrets.io/v1beta1
      kind: ClusterSecretStore
      metadata:
        name: default
      spec:
        provider:
          aws:
            service: SecretsManager
            region: ${var.region}
            auth:
              jwt:
                serviceAccountRef:
                  name: ${local.es_service_account_name}
                  namespace: external-secrets
    EOF
  ]

  # module.eks_addons가 완료될 때까지 대기
  depends_on = [
    module.eks_addons
  ]
}