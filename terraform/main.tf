provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# Create a static IP for the Load Balancer
resource "google_compute_address" "static_ip" {
  name = "secret-word-ip"
}


# Create SSL Certificate for Load Balancer
resource "google_compute_ssl_certificate" "self_signed_cert" {
  name        = "self-signed-cert"
  private_key = file("certs/privkey.pem")
  certificate = file("certs/fullchain.pem")
}

# Create a health check for Load Balancer
resource "google_compute_http_health_check" "http_health_check" {
  name         = "http-health-check"
  request_path = "/"
  port         = 3000
}

# Create a backend service for the Load Balancer
resource "google_compute_backend_service" "backend_service" {
  name        = "backend-service"
  protocol    = "HTTP"
  timeout_sec = 10

  backend {
    group = google_compute_instance_group.app_instance_group.self_link
  }

  health_checks = [google_compute_http_health_check.http_health_check.self_link]
}

# Create a URL map for the Load Balancer
resource "google_compute_url_map" "url_map" {
  name            = "url-map"
  default_service = google_compute_backend_service.backend_service.self_link
}

# Create an HTTPS proxy for the Load Balancer
resource "google_compute_target_https_proxy" "https_proxy" {
  name             = "https-proxy"
  ssl_certificates = [google_compute_ssl_certificate.self_signed_cert.self_link]
  url_map          = google_compute_url_map.url_map.self_link
}

# Create a global forwarding rule for the Load Balancer
resource "google_compute_global_forwarding_rule" "https_forwarding_rule" {
  name       = "https-forwarding-rule"
  target     = google_compute_target_https_proxy.https_proxy.self_link
  port_range = "443"
  ip_address = google_compute_address.static_ip.address
}

# Create a firewall rule to allow traffic on ports 80, 443, and 3000
resource "google_compute_firewall" "allow_http_https" {
  name    = "allow-http-https"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "3000"]
  }

  target_tags = ["http-server", "https-server"]
}

# Create a VM instance to run Docker containers
resource "google_compute_instance" "app_instance" {
  name         = "secret-word-instance"
  machine_type = "e2-medium"
  zone         = var.zone
  tags         = ["http-server", "https-server"]

  boot_disk {
    initialize_params {
      image = "projects/debian-cloud/global/images/family/debian-10"
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral external IP
    }
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    sudo apt update -y
    sudo apt install -y docker.io
    sudo systemctl start docker
    sudo docker pull ${var.docker_image}
    sudo docker run -d -p 3000:3000 ${var.docker_image}
  EOF
}

# Create an instance group to hold VM instances
resource "google_compute_instance_group" "app_instance_group" {
  name      = "app-instance-group"
  zone      = var.zone
  instances = [google_compute_instance.app_instance.self_link]
}

# Output the Load Balancer IP
output "load_balancer_ip" {
  value = google_compute_address.static_ip.address
}

