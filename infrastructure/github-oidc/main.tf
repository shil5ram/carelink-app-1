data "aws_caller_identity" "current" {}

data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

locals {
  services = [
    "spring-petclinic-admin-server",
    "spring-petclinic-api-gateway",
    "spring-petclinic-config-server",
    "spring-petclinic-customers-service",
    "spring-petclinic-discovery-server",
    "spring-petclinic-vets-service",
    "spring-petclinic-visits-service"
  ]

  ecr_repository_arns = [
    for service in local.services :
    "arn:aws:ecr:us-east-1:${data.aws_caller_identity.current.account_id}:repository/carelink-staging-${service}"
  ]
}

data "aws_iam_policy_document" "github_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:shil5ram/carelink-app-1:ref:refs/heads/feature/aws-eks-deployment"]
    }
  }
}

resource "aws_iam_role" "github_actions" {
  name               = "carelink-app-github-actions-staging"
  assume_role_policy = data.aws_iam_policy_document.github_trust.json

  description = "GitHub Actions staging role for shil5ram/carelink-app-1"
}

data "aws_iam_policy_document" "deployment" {
  statement {
    sid       = "ECRAuthentication"
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    sid    = "PushCarelinkImages"
    effect = "Allow"

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart"
    ]

    resources = local.ecr_repository_arns
  }

  statement {
    sid     = "DescribeStagingCluster"
    effect  = "Allow"
    actions = ["eks:DescribeCluster"]
    resources = [
      "arn:aws:eks:us-east-1:${data.aws_caller_identity.current.account_id}:cluster/carelink-staging-eks"
    ]
  }
}

resource "aws_iam_role_policy" "deployment" {
  name   = "carelink-staging-ecr-eks-deployment"
  role   = aws_iam_role.github_actions.id
  policy = data.aws_iam_policy_document.deployment.json
}
