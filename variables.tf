variable "gcp_project_id" {
  type        = string
  description = "GCP project ID"
}

variable "provider_region" {
  type        = string
  description = "provider region (see. https://cloud.google.com/compute/docs/regions-zones)"
}

# NOTE: available format are https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/service_account#account_id
variable "terraform_service_account_id" {
  type        = string
  description = "account id for the service account used by GitHub Actions"
}

variable "github_username" {
  type        = string
  description = "GitHub user name (e.g. sue445)"
}

variable "github_repository" {
  type        = string
  description = "GitHub repository name (e.g. my-terraform)"
}