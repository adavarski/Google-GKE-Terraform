#Activate GCP APIs
resource "google_project_service" "main_api" {
  project  = var.gcp_project
  service  = "cloudresourcemanager.googleapis.com"    #Cloud Resource Manager API
  disable_dependent_services = true
  disable_on_destroy = true
}

#Activate GCP APIs
resource "google_project_service" "apis" {
  project  = var.gcp_project
  for_each = toset(var.gcp_apis)
  service  = each.key
  disable_dependent_services = true
  disable_on_destroy = true

  depends_on = [
    google_project_service.main_api,
  ]
}