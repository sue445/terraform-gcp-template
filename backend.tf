terraform {
  backend "gcs" {
    # NOTE: variables(var and local) are not allowed here
    bucket = "" # TODO: edit here

    prefix = "terraform/state"
  }
}
