terraform {
  backend "gcs" {
    # NOTE: variables(var and local) are not allowed here
    bucket = "YOUR_GCP_PROJECT_ID-terraform"  # TODO: edit here

    prefix = "terraform/state"
  }
}

resource "google_storage_bucket" "backend" {
  name     = local.backend_bucket_name
  location = local.backend_bucket_location

  versioning {
    enabled = true
  }
}
