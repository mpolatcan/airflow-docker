provider "google" {
  credentials = file(var.credentials_file)
  project = var.project
}


module "nfs_server" {
  source = "./nfs"

  nfs_server_machine_name = var.nfs_server_machine_name
  nfs_server_machine_region = var.nfs_server_machine_region
  nfs_server_machine_zone = var.nfs_server_machine_zone
  nfs_server_machine_vcpus = var.nfs_server_machine_vcpus
  nfs_server_machine_memory_in_mb = var.nfs_server_machine_memory_in_mb
  nfs_server_boot_disk_image = local.gcp_vm_images[var.nfs_server_boot_disk_image]
  nfs_server_boot_disk_size = var.nfs_server_boot_disk_size
  nfs_server_boot_disk_type = local.gcp_gce_disk_types[var.nfs_server_boot_disk_type]
  nfs_server_fileshare_name = var.nfs_server_fileshare_name
  nfs_server_network = var.nfs_server_network
  nfs_server_network_cidr = var.nfs_server_network == "default" ? local.gcp_default_network_cidrs[var.nfs_server_machine_region] : var.nfs_server_network_cidr
  nfs_server_sa_scopes = var.nfs_server_sa_scopes
}

module "gke" {
  source = "./gke"

  gke_cluster_name = var.gke_cluster_name
  gke_cluster_location = var.gke_cluster_location
  gke_cluster_network = var.gke_cluster_network
  gke_cluster_node_pool_name = var.gke_cluster_node_pool_name
  gke_cluster_node_pool_initial_node_count = var.gke_cluster_node_pool_initial_node_count
  gke_cluster_node_pool_autoscaling_enabled = var.gke_cluster_node_pool_autoscaling_enabled
  gke_cluster_node_pool_autoscaling_min_node_count = var.gke_cluster_node_pool_autoscaling_min_node_count
  gke_cluster_node_pool_autoscaling_max_node_count = var.gke_cluster_node_pool_autoscaling_max_node_count
  gke_cluster_node_pool_management_auto_repair = var.gke_cluster_node_pool_management_auto_repair
  gke_cluster_node_pool_management_auto_upgrade = var.gke_cluster_node_pool_management_auto_upgrade
  gke_cluster_node_pool_node_config_disk_type = local.gcp_gce_disk_types[var.gke_cluster_node_pool_node_config_disk_type]
  gke_cluster_node_pool_node_config_disk_size_gb = var.gke_cluster_node_pool_node_config_disk_size_gb
  gke_cluster_node_pool_node_config_preemptible = var.gke_cluster_node_pool_node_config_preemptible
  gke_cluster_node_pool_node_config_machine_type = format(
      local.machine_type_fmt,
      var.gke_cluster_node_pool_node_config_machine_vcpus,
      var.gke_cluster_node_pool_node_config_memory_in_mbs
  )
  gke_cluster_node_pool_node_config_local_ssd_count = var.gke_cluster_node_pool_node_config_local_ssd_count
  gke_cluster_node_pool_node_config_oauth_scopes = [
    for scope in var.gke_cluster_node_pool_node_config_oauth_scopes: local.gcp_oauth_scopes[scope]
  ]
}

module "cloud_sql" {
  source = "./cloud_sql"

  cloud_sql_name = var.cloud_sql_name
  cloud_sql_database_version = local.gcp_cloud_sql_database_versions[
    format(
      local.database_version_fmt,
      var.cloud_sql_database_type,
      var.cloud_sql_database_version
    )
  ]
  cloud_sql_region = var.cloud_sql_region
  cloud_sql_settings_tier = var.cloud_sql_settings_tier == null ? format(
      local.database_machine_type_fmt,
      var.cloud_sql_settings_machine_vcpus,
      var.cloud_sql_settings_machine_memory_in_mbs
  ) : var.cloud_sql_settings_tier
  cloud_sql_settings_disk_type = local.gcp_cloud_sql_disk_types[var.cloud_sql_settings_disk_type]
  cloud_sql_settings_disk_size = var.cloud_sql_settings_disk_size
  cloud_sql_settings_disk_autoresize = var.cloud_sql_settings_disk_autoresize
  cloud_sql_user_name = var.cloud_sql_user_name
  cloud_sql_user_password = var.cloud_sql_user_password
}

module "memorystore" {
  source = "./memorystore"

  memorystore_instance_name = var.memorystore_instance_name
  memorystore_instance_memory_size_gb = var.memorystore_instance_memory_size_gb
  memorystore_redis_version = local.gcp_memorystore_redis_versions[var.memorystore_redis_version]
  memorystore_display_name = var.memorystore_display_name
  memorystore_tier = local.gcp_memorystore_tiers[var.memorystore_tier]
  memorystore_location_id = var.memorystore_location_id
  memorystore_alternative_location_id = var.memorystore_alternative_location_id
}