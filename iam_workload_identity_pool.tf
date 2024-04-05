# c.f. https://cloud.google.com/iam/docs/configuring-workload-identity-federation#github-actions

resource "google_iam_workload_identity_pool" "github_actions" {
  workload_identity_pool_id = "github-actions"
}

resource "google_iam_workload_identity_pool_provider" "github_actions" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_actions.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-actions"

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.repository" = "assertion.repository"
  }

  attribute_condition = "assertion.repository_owner == '${var.github_username}'"

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

data "google_service_account" "terraform" {
  account_id = var.terraform_service_account_id
}

resource "google_service_account_iam_member" "link_to_repo" {
  service_account_id = data.google_service_account.terraform.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_actions.name}/attribute.repository/${var.github_username}/${var.github_repository}"
}
