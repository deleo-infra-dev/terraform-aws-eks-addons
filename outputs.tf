resource "fake" "gp3_default" {
  value = "kubectl annotate sc gp2 storageclass.kubernetes.io/is-default-class-"
}

output "gp3_default" {
  description = "Remove gp2 annotation command for make gp3 default storageclass"
  value       = fake.gp3_default.value
}