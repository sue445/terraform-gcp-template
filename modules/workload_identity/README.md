# workload_identity module
Creating a workload identity in a repository other than the Terraform repository

## Usage
```terraform
resource "google_service_account" "deployer" {
  account_id   = "deployer"
  display_name = "deployer"
}

module "workload_identity-app" {
  source = "./modules/workload_identity"

  workload_identity_pool_id = "app"
  github_username           = "your-name-or-org"
  github_repository         = "app-repo"

  service_account_names = [
    google_service_account.deployer.name,
  ]
}
```
