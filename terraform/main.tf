provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# Reserve a static external IP
resource "google_compute_address" "static_ip" {
  name = "secret-word-ip"
}

# HTTP Health Check
resource "google_compute_http_health_check" "health_check" {
  name         = "http-health-check"
  request_path = "/"
  port         = 3000
}

# Instance template with Docker installed
resource "google_compute_instance" "app_instance" {
  name         = "secret-word-instance"
  machine_type = "e2-medium"
  zone         = var.zone
  tags         = ["http-server"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt update -y
    apt install -y docker.io
    systemctl start docker
    docker pull ${var.docker_image}
    docker run -d -p 3000:3000 -e SECRET_WORD=banana ${var.docker_image}
  EOF
}

# Managed instance group to put in backend service
resource "google_compute_instance_group" "instance_group" {
  name      = "app-instance-group"
  zone      = var.zone
  instances = [google_compute_instance.app_instance.self_link]
}

# Backend service
resource "google_compute_backend_service" "backend_service" {
  name          = "app-backend"
  protocol      = "HTTP"
  timeout_sec   = 10
  health_checks = [google_compute_http_health_check.health_check.self_link]

  backends {
    group = google_compute_instance_group.instance_group.self_link
  }
}

# URL Map
resource "google_compute_url_map" "url_map" {
  name = "url-map"
  default_backend_service = google_compute_backend_service.backend_service.self_link
}

# Target HTTP proxy
resource "google_compute_target_http_proxy" "http_proxy" {
  name    = "http-proxy"
  url_map = google_compute_url_map.url_map.self_link
}

# Global forwarding rule on port 80 (HTTP)
resource "google_compute_global_forwarding_rule" "http_forwarding_rule" {
  name       = "http-forwarding-rule"
  ip_address = google_compute_address.static_ip.address
  port_range = "80"
  target     = google_compute_target_http_proxy.http_proxy.self_link
}
