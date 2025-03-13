
################################################################################
# [ Data ] #
## - Data for the EKS Cluster Auth
################################################################################
data "aws_eks_cluster_auth" "this" {
  name = var.cluster_name
}

################################################################################
# [ kubernetes ] #
## - Kubernetes Provider
################################################################################
provider "kubernetes" {
  host                   = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
  token                  = data.aws_eks_cluster_auth.this.token
}

################################################################################
# [ kubectl ] #
## - Kubectl Provider
################################################################################
provider "kubectl" {
  apply_retry_count      = 5
  host                   = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
  load_config_file       = false
  token                  = data.aws_eks_cluster_auth.this.token
}

################################################################################
# [ helm ] #
## - Helm Provider
################################################################################
provider "helm" {
  kubernetes {
    host                   = var.cluster_endpoint
    cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

################################################################################
# [ terraform ] #
## - Terraform Provider
################################################################################  
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.47"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.20"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.9"
    }
    fake = {
      source  = "rayshoo/fake"
      version = "1.0.0"
    }
  }
}