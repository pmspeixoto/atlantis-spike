# Static files bucket
resource "google_storage_bucket" "static_files" {
  provider = google
  name     = "gg-static-files"
  location = "EU"
}

# Make bucket public
resource "google_storage_default_object_access_control" "static_files_public_read" {
  bucket = google_storage_bucket.static_files.name
  role   = "READER"
  entity = "allUsers"
}

# Reserve an external IP
resource "google_compute_global_address" "static_files" {
  provider = google
  name     = "static-lb-ip" 
}

# Add the bucket as a CDN backend
resource "google_compute_backend_bucket" "static_files" {
  provider    = google
  name        = "gg-static-files-backend"
  description = "Contains getground static files"
  bucket_name = google_storage_bucket.static_files.name
  enable_cdn  = true
}

# Create HTTPS certificate
resource "google_compute_managed_ssl_certificate" "static_files" {
  provider = google-beta
  name     = "gg-static-files-ssl-cert"
  managed {
    domains = ["static1.getground.co.uk"]
  }
}

# GCP URL MAP
resource "google_compute_url_map" "static_files" {
  provider        = google
  name            = "gg-static-files-map"
  default_service = google_compute_backend_bucket.static_files.self_link
}

# GCP target proxy
resource "google_compute_target_https_proxy" "static_files" {
  provider         = google
  name             = "gg-static-files-target-proxy"
  url_map          = google_compute_url_map.static_files.self_link
  ssl_certificates = [google_compute_managed_ssl_certificate.static_files.self_link]
}

# GCP forwarding rule
resource "google_compute_global_forwarding_rule" "static_files" {
  provider              = google
  name                  = "gg-static-files-forwarding-rule"
  load_balancing_scheme = "EXTERNAL"
  ip_address            = google_compute_global_address.static_files.address
  ip_protocol           = "TCP"
  port_range            = "443"
  target                = google_compute_target_https_proxy.static_files.self_link
}