terraform {
  required_providers {
    google = {
      source = "hashicorp/google"

      # c.f. https://github.com/hashicorp/terraform-provider-google/blob/main/CHANGELOG.md
      version = "6.28.0"
    }
    google-beta = {
      source = "hashicorp/google-beta"

      # c.f. https://github.com/hashicorp/terraform-provider-google-beta/blob/main/CHANGELOG.md
      version = "6.28.0"
    }
  }
  required_version = ">= 1.0"
}
