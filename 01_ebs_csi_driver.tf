################################################################################
# EKS Cluster
# - https://aws.github.io/aws-eks-best-practices/security/iam/#use-irsa-for-csi-driver
################################################################################
# data "aws_eks_cluster" "this" {
#   name = var.cluster_name
# }

################################################################################
# IAM Policy for EBS CSI Driver
################################################################################
data "aws_iam_policy" "ebs_csi_policy" {
  name = "AmazonEBSCSIDriverPolicy"
}

# trunk-ignore(checkov/CKV_TF_1)
################################################################################
# IRSA for EBS CSI Driver
## - https://aws.github.io/aws-eks-best-practices/security/iam/#use-irsa-for-csi-driver
################################################################################
module "irsa-ebs-csi" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "4.7.0"

  create_role                   = true
  role_name_prefix             = "AmazonEKSTFEBSCSIRole-"
  provider_url                 = var.oidc_provider
  role_policy_arns             = [data.aws_iam_policy.ebs_csi_policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
}


################################################################################
# Storage Class
## - https://aws.github.io/aws-eks-best-practices/storage/ebs/#use-gp3-storage-class
################################################################################
resource "kubectl_manifest" "ebs_gp3_storage_class" {
  yaml_body = <<-YAML
    apiVersion: storage.k8s.io/v1
    kind: StorageClass
    metadata:
      annotations:
        storageclass.kubernetes.io/is-default-class: "true"
      name: gp3
    provisioner: ebs.csi.aws.com
    parameters:
      type: gp3
      csi.storage.k8s.io/fstype: ext4
  YAML
}

################################################################################
# Storage Class
## - https://aws.github.io/aws-eks-best-practices/storage/ebs/#use-gp3-storage-class
################################################################################
resource "kubectl_manifest" "ebs_gp3_full_storage_class" {
  yaml_body = <<-YAML
    apiVersion: storage.k8s.io/v1
    kind: StorageClass
    metadata:
      name: gp3-full
    provisioner: ebs.csi.aws.com
    parameters:
      type: gp3
      iops: "5000"
      throughput: "300"
  YAML
}