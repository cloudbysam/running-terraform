variable "allowed_repos_branches" {
  description = "Github repos/branches allowed to assume the IAM role."
  type = list(object({
    org = string
    repo = string
    branch = string
  }))

  # Example
  # allowed_repos_branches = [
  #     {
  #         org = "cloudbysam"
  #         repo = "running-terraform"
  #         branch = "main"
  #     }
  # ]
}