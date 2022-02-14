# terraform-gcp-template
[Terraform](https://www.terraform.io/) template for [GCP](https://cloud.google.com/)

## [Workflow](.github/workflows/terraform.yml) features
* Authenticating via [Workload Identity Federation](https://cloud.google.com/iam/docs/configuring-workload-identity-federation#github-actions)
* Run `terraform apply`
  * Automatically running on `main` branch
  * Manual running on any branch
* Run `terraform plan`, `terraform fmt` and [tflint](https://github.com/terraform-linters/tflint)
* Comment the result of `terraform plan` to PullRequest
* Slack notification

## Requirements
* GitHub Actions
* Terraform v1.0+

## Usage of this template
### 1. Install tools
* [tfenv](https://github.com/tfutils/tfenv)
* [Cloud SDK](https://cloud.google.com/sdk/docs/install)
  * You can also use the Cloud SDK already installed in [Cloud Shell](https://cloud.google.com/shell)

### 2. Create a repository using this template

### 3. Setup Cloud SDK
```bash
gcloud auth application-default login
gcloud config set project ${GCP_PROJECT_ID}
```

### 4. Prepare for Deployment Manager
At first, enable [Cloud Deployment Manager V2 API](https://console.cloud.google.com/marketplace/product/google/deploymentmanager.googleapis.com)

Add `roles/iam.securityAdmin` to `[GCP_PROJECT_NUMBER]@cloudservices.gserviceaccount.com`

```bash
gcloud projects add-iam-policy-binding ${GCP_PROJECT_ID} --member=serviceAccount:${GCP_PROJECT_NUMBER}@cloudservices.gserviceaccount.com --role=roles/iam.securityAdmin
```

* c.f. https://cloud.google.com/sdk/gcloud/reference/projects/add-iam-policy-binding
* NOTE: This is required for Deployment Manager to bind the IAM role to the Terraform service account.

### 5. Run Deployment Manager
Download [deployment-manager/setup-terraform.jinja](deployment-manager/setup-terraform.jinja) and [deployment-manager/setup-terraform.jinja.schema](deployment-manager/setup-terraform.jinja.schema)

Run Deployment Manager

```bash
gcloud deployment-manager deployments create setup-terraform --template /path/to/setup-terraform.jinja --properties backendBucketName:${BACKEND_BUCKET_NAME},backendBucketLocation:${BACKEND_BUCKET_LOCATION}
```

#### Properties
* `backendBucketName` **(Required)**
  * Bucket name used as the backend of Terraform
  * c.f. https://www.terraform.io/language/settings/backends/gcs
* `backendBucketLocation` (optional)
  * Location of backend bucket (e.g. `us`, `us-central1`)
  * c.f. https://cloud.google.com/storage/docs/locations
  * default: `us`

### 6. Register secrets to GitHub repository
* `SLACK_WEBHOOK` (optional)
  * Create from https://slack.com/apps/A0F7XDUAZ

### 7. Edit files for local apply
#### [.terraform-version](.terraform-version)
* Upgrade to the latest version if necessary

#### [terraform.tfvars](terraform.tfvars)
Edit followings

* `gcp_project_id`
  * GCP project ID
* `provider_region`
  * Provider region
  * see. https://cloud.google.com/compute/docs/regions-zones
* `terraform_service_account_id`
  * Account ID for the service account used by GitHub Actions
  * This is usually `terraform` when service account is created by [deployment-manager/setup-terraform.jinja](deployment-manager/setup-terraform.jinja)
* `github_username`
  * GitHub user name (e.g. `octocat`)
* `github_repository`
  * GitHub repository name (e.g. `Hello-World`)

#### [backend.tf](backend.tf)
Edit followings

* `terraform.backend.bucket`
  * Same to `BACKEND_BUCKET_NAME`

#### [versions.tf](versions.tf)
Upgrade to the latest version if necessary

* `terraform.required_providers.google.version`
* `terraform.required_providers.google-beta.version`
* `terraform.required_version`

### 8. Run Terraform from local
```bash
tfenv install

terraform init -upgrade
git add .terraform.lock.hcl
git commit -m "terraform init -upgrade"

terraform plan
terraform apply
```

### 9. Edit file for GitHub Actions
#### [.github/workflows/terraform.yml](.github/workflows/terraform.yml)
Edit followings

* `TERRAFORM_VERSION`
  * Same to [.terraform-version](.terraform-version)
* `WORKLOAD_IDENTITY_PROVIDER`
  * This is created by Terraform
  * See. https://console.cloud.google.com/iam-admin/workload-identity-pools
* `SERVICE_ACCOUNT_EMAIL`
  * This is created by Deployment Manager
  * See. https://console.cloud.google.com/iam-admin/serviceaccounts

### 10. Check if GitHub Actions build is executed
`git push` and check your repository

## Maintenance for Terraform repository
### Upgrade Terraform core
1. Check latest version
    * https://github.com/hashicorp/terraform/blob/main/CHANGELOG.md
2. Edit `TERRAFORM_VERSION` in [.github/workflows/terraform.yml](.github/workflows/terraform.yml)
3. Edit [.terraform-version](.terraform-version)
4. Run `tfenv install`

### Upgrade Terraform providers
1. Check latest versions
    * https://github.com/hashicorp/terraform-provider-google/blob/master/CHANGELOG.md
    * https://github.com/hashicorp/terraform-provider-google-beta/blob/master/CHANGELOG.md
2. Edit `terraform.required_providers.google.version` and `terraform.required_providers.google-beta.version` in [versions.tf](versions.tf)
3. Run `terraform init -upgrade`

## Other solution
* https://github.com/sue445/terraform-aws-template
