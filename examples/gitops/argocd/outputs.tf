output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = module.eks_blueprints.configure_kubectl
}

output "get_argocd_admin_password" {
  description = "awscli command to retrieve ArgoCD admin password from AWS SecretsManager"
  value       = "aws secretsmanager get-secret-value --secret-id ${aws_secretsmanager_secret.argocd.name} --region ${local.region} --query 'SecretString' --output text"
}

output "platform_team_configure_kubectl" {
  description = "Configure kubectl for each Platform Team: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = module.eks_blueprints.teams[0].platform_teams_configure_kubectl["admin"]
}

output "team_blue_configure_kubectl" {
  description = "Configure kubectl for each Application Teams: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = module.eks_blueprints.teams[0].application_teams_configure_kubectl["team-blue"]
}
