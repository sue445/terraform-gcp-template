terraform {
  required_providers {
    google = {
      source = "hashicorp/google"

      # c.f. https://github.com/hashicorp/terraform-provider-google/blob/master/CHANGELOG.md
      version = "4.25.0"
    }
    google-beta = {
      source = "hashicorp/google-beta"
      # c.f. https://github.com/hashicorp/terraform-provider-google-beta/blob/master/CHANGELOG.md
      version = "4.24.0"
    }
  }
  required_version = ">= 1.0"
}
