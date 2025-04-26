variable "project_id" {
  description = "Your GCP Project ID"
}

variable "region" {
  default = "us-central1"
}

variable "zone" {
  default = "us-central1-a"
}

variable "docker_image" {
  default = "secret-word-app"
}
