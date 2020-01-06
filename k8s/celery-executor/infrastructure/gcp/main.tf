variable "credentials_file" {type = string}
variable "project" {type = string}

provider "google" {
  credentials = file(var.credentials_file)
  project = var.project
}


module "nfs_server" {
  source = "nfs"

  nfs_server_machine_name = var.nfs_server_machine_name
  nfs_server_machine_region = var.nfs_server_machine_region
  nfs_server_machine_zone = var.nfs_server_machine_zone
  nfs_server_machine_vcpus = var.nfs_server_machine_vcpus
  nfs_server_machine_memory_in_mb = var.nfs_server_machine_memory_in_mb
  nfs_server_boot_disk_image = local.gcp_vm_images[var.nfs_server_boot_disk_image]
  nfs_server_boot_disk_size = var.nfs_server_boot_disk_size
  nfs_server_boot_disk_type = local.gcp_disk_types[var.nfs_server_boot_disk_type]
  nfs_server_fileshare_name = var.nfs_server_fileshare_name
  nfs_server_network = var.nfs_server_network
  nfs_server_network_cidr = var.nfs_server_network == "default" ? local.gcp_default_network_cidrs[var.nfs_server_machine_region] : var.nfs_server_network_cidr
  nfs_server_sa_scopes = var.nfs_server_sa_scopes
}

# ----------------------------------- GKE CLUSTER -----------------------------------
resource "google_container_cluster" "gke_cluster" {
  name = var.gke_cluster_name
  location = var.gke_cluster_location
  master_version = var.gke_cluster_master_version
  network = var.gke_cluster_network

  node_pool {
    name = var.gke_cluster_node_pool_name
    initial_node_count = var.gke_cluster_node_pool_initial_node_count

    autoscaling {
      max_node_count = var.gke_cluster_node_pool_autoscaling_max_node_count
      min_node_count = var.gke_cluster_node_pool_autoscaling_min_node_count
    }

    management {
      auto_repair = var.gke_cluster_node_pool_management_auto_repair
      auto_upgrade = var.gke_cluster_node_pool_management_auto_upgrade
    }

    node_config {
      disk_type = var.gke_cluster_node_pool_node_config_disk_type
      disk_size_gb = var.gke_cluster_node_pool_node_config_disk_size_gb
      preemptible = var.gke_cluster_node_pool_node_config_preemptible
      machine_type = format(
        local.machine_type_fmt,
        var.gke_cluster_node_pool_node_config_machine_vcpus,
        var.gke_cluster_node_pool_node_config_memory_in_mbs
      )

      local_ssd_count = var.gke_cluster_node_pool_node_config_local_ssd_count

      oauth_scopes = [
        for scope in var.gke_cluster_node_pool_node_config_oauth_scopes: local.gcp_oauth_scopes[scope]
      ]
    }
  }
}
# --------------------------------------------------------------------------------------

# ----------------------------------- CLOUD SQL ----------------------------------------
resource "google_sql_database_instance" "cloud_sql_instance" {
  name = var.cloud_sql_name
  database_version = local.gcp_cloud_sql_database_versions[
    format(
      local.database_version_fmt,
      var.cloud_sql_database_type,
      var.cloud_sql_database_version
    )
  ]
  region = var.cloud_sql_region

  settings {
    tier = var.cloud_sql_settings_tier
    disk_size = var.cloud_sql_settings_disk_size
    disk_type = local.gcp_disk_types[var.cloud_sql_settings_disk_type]
    disk_autoresize = var.cloud_sql_settings_disk_autoresize
  }
}

resource "google_sql_user" "cloud_sql_user" {
  instance = google_sql_database_instance.cloud_sql_instance.name
  name = var.cloud_sql_user_name
  password = var.cloud_sql_user_password
}
# ---------------------------------------------------------------------------------------

resource "google_redis_instance" "memorystore_instance" {
  name = var.memorystore_instance_name
  memory_size_gb = var.memorystore_instance_memory_size_gb
  redis_version = local.gcp_memorystore_redis_versions[var.memorystore_redis_version]
  display_name = var.memorystore_display_name
  tier = local.gcp_memorystore_tiers[var.memorystore_tier]
  location_id = var.memorystore_location_id
  alternative_location_id = var.memorystore_alternative_location_id
}