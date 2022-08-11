# Static files bucket
resource "google_storage_bucket" "static_files" {
  provider = google
  name     = "gg-atlantis-spike"
  location = "EU"
}

# Make bucket public
resource "google_storage_default_object_access_control" "static_files_public_read" {
  bucket = google_storage_bucket.static_files.name
  role   = "READER"
  entity = "allUsers"
}

# Add null resource
resource "null_resource" "example" {}