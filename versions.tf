terraform {
  required_providers {
    google = {
      source = "hashicorp/google"

      # c.f. https://github.com/hashicorp/terraform-provider-google/blob/master/CHANGELOG.md
      version = "3.73.0" # Edit here
    }
    google-beta = {
      source = "hashicorp/google-beta"

      # c.f. https://github.com/hashicorp/terraform-provider-google-beta/blob/master/CHANGELOG.md
      version = "3.73.0" # Edit here
    }
  }
  required_version = ">= 1.0" # Edit here
}
