#GCP Global Variables
variable "gcp_project" {
  description = "The name of the GCP Project"
  type        = string
}

variable "gcp_region" {
  description = "Google Cloud region"
  type        = string
}

variable "gcp_zone" {
  description = "Google Cloud Zone"
  type        = string
}

#API Module Specific Variables
variable "gcp_apis" {
  description = "The list of apis to activate within the project"
  type        = list(string)
}

#Buckets Module Specific Variables
variable "bucket_names" {
  description = "The list of names to be givven to the cloud storage buckets"
  type        = list(string)
}

#External Ips Module Specific Variables
variable "ip_names" {
  description = "A list of names for external addresses"
  type        = list(string)
}

#GKE Module Specific Variables
variable "node_config_machine_type" {
  description = "The custom machine type for the cluster's nodes"
  type = string
}

variable "min_cpu_platform" {
  description = "A minimum for the CPU platform"
  type = string
}

variable "preemptible_nodes" {
  description = "Marks preemptible and non preemptible nodes"
  type = bool
}


#variable "headers" {
#  description = "Headers keys + values"
#  type = map(string)
#}


