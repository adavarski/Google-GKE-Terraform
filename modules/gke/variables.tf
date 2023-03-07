variable "gcp_project" {
  type = string
}

variable "gcp_region" {
  type = string
}

variable "gcp_zone" {
  type = string
}

variable "node_config_machine_type" {
  type = string
}

variable "min_cpu_platform" {
  type = string
}

variable "gke_service_account" {
  type = string
}

variable "preemptible_nodes" {
  type = bool
}