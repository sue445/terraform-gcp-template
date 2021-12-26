provider "google" {
  project = var.gcp_project_id
  region  = var.provider_region
}

provider "google-beta" {
  project = var.gcp_project_id
  region  = var.provider_region
}
