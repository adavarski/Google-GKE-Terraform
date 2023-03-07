output "compute_engine_api" {
  value = google_project_service.apis["compute.googleapis.com"].id
}

output "gke_api" {
  value = google_project_service.apis["container.googleapis.com"].id
}

output "iam_api" {
  value = google_project_service.apis["iam.googleapis.com"].id
}

