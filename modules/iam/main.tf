resource "google_service_account" "gke_account" {
  account_id = "kubernetes-service-account"
  display_name = "Kubernetes service account"
}

resource "google_project_iam_member" "gke" {
  project = var.gcp_project
  role    = "roles/owner"
  member  = "serviceAccount:${google_service_account.gke_account.email}"
}

output "gke_account" {
    value = google_service_account.gke_account
}