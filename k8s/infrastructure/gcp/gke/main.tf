resource "google_container_cluster" "gke_cluster" {
  name = var.gke_cluster_name
  location = var.gke_cluster_location
  network = var.gke_cluster_network

  node_pool {
    name = var.gke_cluster_node_pool_name
    initial_node_count = var.gke_cluster_node_pool_initial_node_count

    dynamic autoscaling {
      for_each = var.gke_cluster_node_pool_autoscaling_enabled == false ? [] : [1]
      content {
        max_node_count = var.gke_cluster_node_pool_autoscaling_max_node_count
        min_node_count = var.gke_cluster_node_pool_autoscaling_min_node_count
      }
    }

    management {
      auto_repair = var.gke_cluster_node_pool_management_auto_repair
      auto_upgrade = var.gke_cluster_node_pool_management_auto_upgrade
    }

    node_config {
      disk_type = var.gke_cluster_node_pool_node_config_disk_type
      disk_size_gb = var.gke_cluster_node_pool_node_config_disk_size_gb
      preemptible = var.gke_cluster_node_pool_node_config_preemptible
      machine_type = var.gke_cluster_node_pool_node_config_machine_type

      local_ssd_count = var.gke_cluster_node_pool_node_config_local_ssd_count

      oauth_scopes = var.gke_cluster_node_pool_node_config_oauth_scopes
    }
  }
}