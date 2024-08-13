terraform {
  backend "gcs" {
    bucket  = "vz-terraform-bucket"
    prefix  = "terraform/state"
  }
}