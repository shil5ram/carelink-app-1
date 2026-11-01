output "github_actions_role_arn" {
  description = "IAM role ARN for the CareLink GitHub Actions workflow"
  value       = aws_iam_role.github_actions.arn
}

output "github_oidc_provider_arn" {
  value = data.aws_iam_openid_connect_provider.github.arn
}
