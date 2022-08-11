terraform {
  backend "gcs" {
    bucket  = "tf-state-staging-backend-236514"
    prefix  = "terraform/state/gcs"
  }

  required_providers {
    google = {
      version = "~> 3.51.0"
    }
    google-beta = {
      version = "~> 3.51.0"
    }
  }
}

provider "google" {
  project     = var.project
  region      = var.region
}

provider "google-beta" {
  project     = var.project
  region      = var.region
}
