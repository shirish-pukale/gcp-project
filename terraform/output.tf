output "load_balancer_ip" {
  description = "Access your app at http://<this_ip>"
  value       = google_compute_address.static_ip.address
}

