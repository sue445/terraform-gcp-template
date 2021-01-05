locals {
  gcp_project_id = "YOUR_GCP_PROJECT_ID"

  // c.f. https://cloud.google.com/compute/docs/regions-zones
  provider_region = "asia-northeast1"

  // c.f. https://cloud.google.com/storage/docs/locations
  backend_bucket_location = "asia-northeast1"

  backend_bucket_name = "${local.gcp_project_id}-terraform"
}

provider "google" {
  project = local.gcp_project_id
  region  = local.provider_region
}

provider "google-beta" {
  project = local.gcp_project_id
  region  = local.provider_region
}
