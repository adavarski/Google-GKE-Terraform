locals {
  names_set    = toset(var.ip_names)
  ips_list     = [for name in var.ip_names : google_compute_global_address.ips[name]]
}

resource "google_compute_global_address" "ips" {
  for_each      = local.names_set
  name          = each.key
}

output "integration_hub_address" {
  value = google_compute_global_address.ips["client1-static-ip"].address
}
