# terraform-gcp-template
[Terraform](https://www.terraform.io/) template for [Google Cloud (GCP)](https://cloud.google.com/)

## [Workflow](.github/workflows/terraform.yml) features
* Authenticating via [Workload Identity Federation](https://cloud.google.com/iam/docs/configuring-workload-identity-federation#github-actions)
* Run `terraform apply`
  * Automatically running on `main` branch
  * Manual running on any branch
* Run `terraform plan`, `terraform fmt` and [tflint](https://github.com/terraform-linters/tflint)
* Post `terraform plan` report to PullRequest comment and Job Summaries
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
gcloud auth login
# or
gcloud auth application-default login
```

### 4. Run setup-terraform.sh
Download [scripts/setup-terraform.sh](scripts/setup-terraform.sh) and run

e.g.

```bash
# Download and add permission
wget https://raw.githubusercontent.com/sue445/terraform-gcp-template/refs/heads/main/scripts/setup-terraform.sh
chmod 755 setup-terraform.sh

# Run as dry run mode
./setup-terraform.sh --project your-gcp-project-id --github-username octocat --github-repository your-gcp-project-terraform --dry-run

# Actually create resources
./setup-terraform.sh --project your-gcp-project-id --github-username octocat --github-repository your-gcp-project-terraform
```

`setup-terraform.sh` will perform following

* Enable APIs
* Create Service Account for Terraform
* Grant minimum IAM roles to Service Account
* Create GCS bucket for backend
* Create Workload Identity Pool and Provider for GitHub Actions

#### Parameters
* `--project` **(Required)**
  * Google Project ID
* `--backend` 
  * Bucket name used as the backend of Terraform
  * c.f. https://www.terraform.io/language/settings/backends/gcs
  * default: `${PROJECT_ID}-terraform`
* `--location`
  * Location of backend bucket (e.g. `us`, `us-central1`)
  * c.f. https://cloud.google.com/storage/docs/locations
  * default: `us`
* `--github-username` **(Required)**
  * GitHub user name (e.g. `octocat`)
* `--github-repository` **(Required)**
  * GitHub repository name (e.g. `your-gcp-project-terraform`)
* `--dry-run`
  * Run as dry run mode
* `-help`, `-h`
  * Show usage

### 5. Register secrets to GitHub repository
* `SLACK_WEBHOOK` (optional)
  * Create from https://slack.com/apps/A0F7XDUAZ

### 6. Edit files
#### [.terraform-version](.terraform-version)
* Upgrade to the latest version if necessary

#### [terraform.tfvars](terraform.tfvars)
Edit followings

* `gcp_project_id`
  * GCP project ID
* `provider_region`
  * Provider region
  * see. https://cloud.google.com/compute/docs/regions-zones

#### [backend.tf](backend.tf)
Edit followings

* `terraform.backend.bucket`
  * Same to `--backend`

#### [versions.tf](versions.tf)
Upgrade to the latest version if necessary

* `terraform.required_providers.google.version`
* `terraform.required_providers.google-beta.version`
* `terraform.required_version`

### 8. Run Terraform from local
```bash
tfenv install

terraform init

# Run followings if you upgraded providers
terraform init -upgrade
git add .terraform.lock.hcl
git commit -m "terraform init -upgrade"

terraform plan
```

### 9. Edit file for GitHub Actions
#### [.github/workflows/terraform.yml](.github/workflows/terraform.yml)
Edit followings

* `WORKLOAD_IDENTITY_PROVIDER`
  * This is created by [scripts/setup-terraform.sh](scripts/setup-terraform.sh)
  * See. https://console.cloud.google.com/iam-admin/workload-identity-pools
* `SERVICE_ACCOUNT_EMAIL`
  * This is created by [scripts/setup-terraform.sh](scripts/setup-terraform.sh)
  * See. https://console.cloud.google.com/iam-admin/serviceaccounts

### 10. Check if GitHub Actions build is executed
`git push` and check your repository

## Maintenance for Terraform repository
### Upgrade Terraform core
1. Check latest version
    * https://github.com/hashicorp/terraform/blob/main/CHANGELOG.md
2. Edit [.terraform-version](.terraform-version)
3. Run `tfenv install`

### Upgrade Terraform providers (automatically)
1. Edit [.github/dependabot.yml](.github/dependabot.yml)
2. Wait for Dependabot to create a PullRequests

### Upgrade Terraform providers (manually)
1. Check latest versions
    * https://github.com/hashicorp/terraform-provider-google/blob/main/CHANGELOG.md
    * https://github.com/hashicorp/terraform-provider-google-beta/blob/main/CHANGELOG.md
2. Edit `terraform.required_providers.google.version` and `terraform.required_providers.google-beta.version` in [versions.tf](versions.tf)
3. Run `terraform init -upgrade`

### Upgrade tflint plugins (automatically)
To automatically upgrade tflint plugins, [renovate](https://docs.renovatebot.com/) is required.

Please set up renovate using the following as a reference.

https://docs.renovatebot.com/getting-started/running/

## Other solution
* https://github.com/sue445/terraform-aws-template
