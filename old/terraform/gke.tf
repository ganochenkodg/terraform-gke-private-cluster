variable "gke_num_nodes" {
  default     = 1
  description = "number of gke nodes per zone"
}

# GKE cluster
resource "google_container_cluster" "cluster" {
  name     = "${var.project_id}-gke"
  location = var.region
  
  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name

  logging_service          = "logging.googleapis.com/kubernetes"
  monitoring_service       = "monitoring.googleapis.com/kubernetes"
  networking_mode          = "VPC_NATIVE"

  release_channel {
    channel = "REGULAR"
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = "k8s-pod-range"
    services_secondary_range_name = "k8s-service-range"
  }

  addons_config {
    network_policy_config {
      disabled = false
    }
  }

  network_policy {
    enabled= true
    provider= "CALICO"
  }

  enable_shielded_nodes= true

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }
}

# nodepool
resource "google_container_node_pool" "cluster_pool" {
  name       = google_container_cluster.cluster.name
  location   = var.region
  cluster    = google_container_cluster.cluster.name
  node_count = var.gke_num_nodes
  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    disk_size_gb = 30
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels = {
      env = var.project_id
    }

    # preemptible  = true
    machine_type = "e2-standard-2"
    tags         = ["gke-node", "${var.project_id}-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
    }

    shielded_instance_config {
       enable_integrity_monitoring = true
       enable_secure_boot          = true
    }
  }
}

