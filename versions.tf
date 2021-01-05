terraform {
  required_providers {
    google = {
      source = "hashicorp/google"

      # c.f. https://github.com/hashicorp/terraform-provider-google/blob/master/CHANGELOG.md
      version = "3.51.0"
    }
    google-beta = {
      source = "hashicorp/google-beta"
      # c.f. https://github.com/hashicorp/terraform-provider-google-beta/blob/master/CHANGELOG.md
      version = "3.51.0"
    }
  }
  required_version = ">= 0.14"
}
