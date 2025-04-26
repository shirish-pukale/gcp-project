variable "project_id" {
  description = "GCP project ID"
  default     = "melodic-realm-457907-g8"
}

variable "region" {
  description = "GCP region"
  default     = "us-central1"
}

variable "zone" {
  description = "GCP zone"
  default     = "us-central1-a"
}

variable "docker_image" {
  description = "The Docker image to deploy"
  default     = "secret-word-app"
}

variable "domain_name" {
  description  = "The domain name"
  default      = "mydomain"
}
