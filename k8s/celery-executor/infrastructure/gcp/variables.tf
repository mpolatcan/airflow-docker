locals {
  machine_type_fmt = "custom-%d-%d"
  database_version_fmt = "%s-%s"
  gcp_default_network_cidrs={
    us-central1 = "10.128.0.0/20"
    europe-west1 = "10.132.0.0/20"
    us-west1 = "10.138.0.0/20"
    asia-east1 = "10.140.0.0/20"
    us-east1 = "10.142.0.0/20"
    asia-northeast1 = "10.146.0.0/20"
    asia-southeast1 = "10.148.0.0/20"
    us-east4 = "10.150.0.0/20"
    australia-southeast1 = "10.152.0.0/20"
    europe-west2 = "10.154.0.0/20"
    europe-west3 = "10.156.0.0/20"
  }

  gcp_vm_images={
    debian_9 = "debian-cloud/debian-9"
    debian_10 = "debian-cloud/debian-10"
    ubuntu_1604 = "ubuntu-os-cloud/ubuntu-1604-lts"
    ubuntu_1604_minimal = "ubuntu-os-cloud/ubuntu-minimal-1604-lts"
    ubuntu_1804 = "ubuntu-os-cloud/ubuntu-1804-lts"
    ubuntu_1804_minimal = "ubuntu-os-cloud/ubuntu-minimal-1804-lts"
    ubuntu_1904 = "ubuntu-os-cloud/ubuntu-1904"
    ubuntu_1904_minimal = "ubuntu-os-cloud/ubuntu-minimal-1904"
    ubuntu_1910 = "ubuntu-os-cloud/ubuntu-1910"
    ubuntu_1910_minimal = "ubuntu-os-cloud/ubuntu-minimal-1910"
  }

  gcp_disk_types={
    ssd = "pd-ssd"
    hdd = "pd-standard"
  }

  gcp_memorystore_tiers={
    basic = "BASIC"
    ha = "STANDARD_HA"
  }

  gcp_cloud_sql_database_versions={
    mysql-5.6 = "MYSQL_5_6"
    mysql-5.7 = "MYSQL_5_7"
    postgres-9.6 = "POSTGRES_9_6"
    postgres_11 = "POSTGRES_11"
  }

  gcp_memorystore_redis_versions={
    4.0 = "REDIS_4_0"
    3.2 = "REDIS_3_2"
  }

  gcp_oauth_scopes={
    cloud-platform = "https://www.googleapis.com/auth/cloud-platform"
  }
}

# ------------------------ NFS SERVER SETTINGS -----------------------
variable "nfs_server_fileshare_name" {type = string}
variable "nfs_server_machine_name" {type = string}
variable "nfs_server_machine_region" {type = string}
variable "nfs_server_machine_zone" {type = string}
variable "nfs_server_machine_vcpus" {
  type = number
  default = ""
}
variable "nfs_server_machine_memory_in_mb" {
  type = number
  default = ""
}
variable "nfs_server_boot_disk_image" {
  type = string
  default = ""
}
variable "nfs_server_boot_disk_size" {
  type = number
  default = ""
}
variable "nfs_server_boot_disk_type" {
  type = string
  default = ""
}
variable "nfs_server_network" {
  type = string
  default = "default"
}
variable "nfs_server_network_cidr" {
  type = string
  default = null
}
variable "nfs_server_sa_scopes" {
  type = list(string)
  default = []
}
# --------------------------------------------------------------------

# ---------------------- GKE CLUSTER SETTINGS ------------------------
variable "gke_cluster_name" {type = string}
variable "gke_cluster_location" {type = string}
variable "gke_cluster_master_version" {
  type = string
  default = null
}
variable "gke_cluster_network" {
  type = string
  default = "default"
}
variable "gke_cluster_node_pool_name" {
  type = string
  default = "default-pool"
}
variable "gke_cluster_node_pool_initial_node_count" {
  type = string
  default = 1
}
variable "gke_cluster_node_pool_autoscaling_min_node_count" {
  type = number
  default = null
}
variable "gke_cluster_node_pool_autoscaling_max_node_count" {
  type = number
  default = null
}
variable "gke_cluster_node_pool_management_auto_repair" {
  type = bool
  default = true
}
variable "gke_cluster_node_pool_management_auto_upgrade" {
  type = bool
  default = false
}
variable "gke_cluster_node_pool_node_config_disk_type" {
  type = string
  default = "hdd"
}
variable "gke_cluster_node_pool_node_config_disk_size_gb" {
  type = number
  default = 100
}
variable "gke_cluster_node_pool_node_config_preemptible" {
  type = bool
  default = false
}
variable "gke_cluster_node_pool_node_config_machine_vcpus" {
  type = number
  default = 2
}
variable "gke_cluster_node_pool_node_config_memory_in_mbs" {
  type = number
  default = 4096
}
variable "gke_cluster_node_pool_node_config_local_ssd_count" {
  type = number
  default = null
}
variable "gke_cluster_node_pool_node_config_oauth_scopes" {type = list(string)}
# --------------------------------------------------------------------

# ------------------------ CLOUD SQL SETTINGS ------------------------
variable "cloud_sql_name" {type = string}
variable "cloud_sql_database_type" {
  type = string
  default = "postgres"
}
variable "cloud_sql_database_version" {
  type = string
  default = "11"
}
variable "cloud_sql_region" {type = string}
variable "cloud_sql_settings_tier" {
  type = string
  default = "basic"
}
variable "cloud_sql_settings_disk_size" {
  type = number
  default = 100
}
variable "cloud_sql_settings_disk_type" {
  type = string
  default = "hdd"
}
variable "cloud_sql_settings_disk_autoresize" {
  type = bool
  default = false
}
variable "cloud_sql_user_name" {
  type = string
  default = "postgres"
}
variable "cloud_sql_user_password" {type = string}
# --------------------------------------------------------------------

# ------------------------ MEMORYSTORE SETTINGS ----------------------
variable "memorystore_instance_name" {type = string}
variable "memorystore_instance_memory_size_gb" {type = number}
variable "memorystore_redis_version" {
  type = string
  default = "4.0"
}
variable "memorystore_display_name" {
  type = string
  default = null
}
variable "memorystore_tier" {
  type = string
  default = "basic"
}
variable "memorystore_location_id" {type = string}
variable "memorystore_alternative_location_id" {
  type = string
  default = null
}
# --------------------------------------------------------------------