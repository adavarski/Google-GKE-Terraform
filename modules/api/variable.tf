variable "gcp_project" {
  description = "The name of the GCP Project"
  type        = string
}

variable "gcp_apis" {
  description = "The list of apis to activate within the project"
  type        = list(string)
}