#GKE MASTER CLUSTER CONFIGURATION
resource "google_container_cluster" "cluster" {
  provider = google-beta
  project = var.gcp_project
  location = var.gcp_zone
  name = "dev1-gke"
  #node_locations = list("europe-west3-b", "europe-west3-c")
  
  
  #Master Version for GKE
  release_channel {
    channel = "UNSPECIFIED"
  }

  #Networking options for GKE
  networking_mode = "VPC_NATIVE"

  #GKE Security Options

  #Shielded GKE nodes provide strong cryptographic identity for nodes joining a cluster.
  enable_shielded_nodes = true
   

  #IP allocation policy block - Defining the networks for pods and services in our cluster
  ip_allocation_policy {
    cluster_ipv4_cidr_block  = ""
    services_ipv4_cidr_block = ""
  }

  #Intranode Visibility
  ##Enabling intranode visibility makes your intranode Pod-to-Pod traffic visible to the GCP networking fabric.
  ###With this feature, you can use VPC flow logging or other VPC features for intranode traffic.
  enable_intranode_visibility = true


  #Network policy option
  network_policy {
    enabled = false
  }

  #GKE Cluster Automation Options

  #To specify regular times for maintenance, enable maintenance windows. 
  ##Normally, routine Kubernetes Engine maintenance may run at any time on your cluster.
    
  maintenance_policy {
    daily_maintenance_window {
      start_time = "01:00"
    }
  }

  #Addons Cofiguration
  addons_config {
    http_load_balancing {
      disabled = false
    }
    
    #NodeLocal DNSCache improves Cluster DNS performance by running a DNS caching agent on cluster nodes as a DaemonSet.
    dns_cache_config {
      enabled = true
    }
    
    network_policy_config {
      disabled = true
    }
  }

  #GKE Node Pools Options  
  remove_default_node_pool = true

  initial_node_count = 1

  timeouts {
    create = "30m"
    update = "40m"
  }
}

resource "google_container_node_pool" "node_pool" {
  # The location (region or zone) in which the cluster resides
  location = google_container_cluster.cluster.location

  count = 1

  # The name of the node pool. Instance groups created will have the cluster
  # name prefixed automatically.
  name = "default-pool"

  # The cluster to create the node pool for.
  cluster = google_container_cluster.cluster.name

  project = var.gcp_project

  initial_node_count = 3

  # Configuration required by cluster autoscaler to adjust the size of the node pool to the current cluster usage.
  autoscaling {
    # Minimum number of nodes in the NodePool. Must be >=0 and <= max_node_count.
    min_node_count = 3

    # Maximum number of nodes in the NodePool. Must be >= min_node_count.
    max_node_count = 15
  }


  # Node management configuration, wherein auto-repair and auto-upgrade is configured.
  management {
    # Whether the nodes will be automatically repaired.
    auto_repair = true

    # Whether the nodes will be automatically upgraded.
    auto_upgrade = true
  }

  upgrade_settings {
    max_surge = 1
    max_unavailable = 0
  }

  timeouts {
    create = "30m"
    update = "20m"
  }

  # Parameters used in creating the cluster's nodes.
  node_config {
    # The name of a Google Compute Engine machine type. Defaults to
    # n1-standard-1.
    machine_type = var.node_config_machine_type

    # Size of the disk attached to each node, specified in GB. The smallest
    # allowed disk size is 10GB. Defaults to 100GB.
    disk_size_gb = 100

    # Type of the disk attached to each node (e.g. 'pd-standard' or 'pd-ssd').
    # If unspecified, the default disk type is 'pd-standard'
    disk_type = "pd-standard"

    service_account = var.gke_service_account

    # A boolean that represents whether or not the underlying node VMs are
    # preemptible. See the official documentation for more information.
    # Defaults to false.
    preemptible = var.preemptible_nodes

    min_cpu_platform = var.min_cpu_platform
    
    # The set of Google API scopes to be made available on all of the node VMs
    # under the "default" service account. These can be either FQDNs, or scope
    # aliases. The cloud-platform access scope authorizes access to all Cloud
    # Platform services, and then limit the access by granting IAM roles
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
    # The metadata key/value pairs assigned to instances in the cluster.
    metadata = {
      disable-legacy-endpoints = true
    }
  }
}
