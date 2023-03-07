terraform {
  backend "gcs" {
  bucket  = "dev1-gke-terraform"
}
}

#GCP Providers needed for infrastructure provisioning
provider "google" {
  credentials = file("service-account.json")
  project     = var.gcp_project
  region      = var.gcp_region
  zone        = var.gcp_zone
}

provider "google-beta" {
  credentials = file("service-account.json")
  project     = var.gcp_project
  region      = var.gcp_region
  zone        = var.gcp_zone
}

#Activate GCP APIs
module "api" {
  source       =  "./modules/api"
  gcp_project  = var.gcp_project
  gcp_apis     = var.gcp_apis
}

#Create Service Accounts
module "iam" {
  source       = "./modules/iam"
  gcp_project  = var.gcp_project

  depends_on      = [module.api.iam_api,]
}

#Reserve external IP addresses
module "network" {
  source          = "./modules/network"
  gcp_project     = var.gcp_project
  gcp_region      = var.gcp_region
  ip_names        = var.ip_names

  depends_on      = [module.api.compute_engine_api,]
}

#GKE provisioning
module "gke" {
  source = "./modules/gke"
  gcp_project              = var.gcp_project
  gcp_region               = var.gcp_region
  gcp_zone                 = var.gcp_zone
  gke_service_account      = module.iam.gke_account.email
  node_config_machine_type = var.node_config_machine_type
  min_cpu_platform         = var.min_cpu_platform
  preemptible_nodes        = var.preemptible_nodes

  depends_on               = [module.api.compute_engine_api, module.api.gke_api, module.iam.gke_account,]
}

