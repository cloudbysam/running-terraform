# Create an IAM OIDC identity provider that trusts GitHub.
resource "aws_iam_openid_connect_provider" "github_actions" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github.certificates[0].sha1_fingerprint]
}

# Fetch GitHub's OIDC thumbprint
data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      identifiers = [aws_iam_openid_connect_provider.github_actions.arn]
      type        = "Federated"
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      
      values = [
        for a in var.allowed_repos_branches :
        "repo:${a["org"]}/${a["repo"]}:ref:refs/heads/${a["branch"]}"
      ]
    }
  }
}

# Create the IAM Role that GitHub Actions will assume
resource "aws_iam_role" "github_actions_role" {
  name               = "github-actions-terraform-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# Attach Administrator access (or a more restrictive policy) so Terraform can manage your infrastructure
resource "aws_iam_role_policy_attachment" "terraform_admin" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Output the AWS Role ARN 
output "github_actions_role_arn" {
  value       = aws_iam_role.github_actions_role.arn
  description = "The ARN of the AWS role"
}
