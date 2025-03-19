################################################################################
# External-DNS
################################################################################

locals {
  # 호스팅되는 영역만 필터링
  external_dns_zones = flatten([
    for zone in var.external_dns_zones : flatten([
        zone.hosting == true ? [zone.name] : []
    ])
  ])

  # Route53 영역 ARN 목록 생성
  external_dns_route53_zone_arns = data.aws_route53_zone.external_dns[*].arn

  # 도메인 필터 문자열 생성
  external_dns_domain_filters = join(",", [for s in var.external_dns_zones : format("%s", s.name)])
}

################################################################################
# Route53 영역 데이터 소스
################################################################################

data "aws_route53_zone" "external_dns" {
  count = length(local.external_dns_zones)
  name  = element(local.external_dns_zones, count.index)
}