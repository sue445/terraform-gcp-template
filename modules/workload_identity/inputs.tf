# NOTE: available format are https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/service_account#account_id
variable "workload_identity_pool_id" {
  type        = string
  description = "workload identity pool id"
}

variable "service_account_names" {
  type        = list(string)
  description = "Service account emails"
}

variable "github_username" {
  type        = string
  description = "GitHub user name (e.g. sue445)"
}

variable "github_repository" {
  type        = string
  description = "GitHub repository name (e.g. my-terraform)"
}
