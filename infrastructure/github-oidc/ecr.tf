locals {
  ecr_repository_names = toset([
    "carelink-staging-spring-petclinic-admin-server",
    "carelink-staging-spring-petclinic-api-gateway",
    "carelink-staging-spring-petclinic-config-server",
    "carelink-staging-spring-petclinic-customers-service",
    "carelink-staging-spring-petclinic-discovery-server",
    "carelink-staging-spring-petclinic-vets-service",
    "carelink-staging-spring-petclinic-visits-service"
  ])
}

resource "aws_ecr_repository" "carelink_services" {
  for_each = local.ecr_repository_names

  name                 = each.value
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Project     = "CareLink"
    Environment = "staging"
    ManagedBy   = "Terraform"
  }
}
