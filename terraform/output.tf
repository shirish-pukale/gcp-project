output "load_balancer_ip" {
  description = "IP address of the Load Balancer"
  value       = google_compute_address.static_ip.address
}
