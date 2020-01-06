credentials_file = "gcp_credentials.json"
project = "mpolatcan-sandbox-246120"

# ------------------------- NFS SETTINGS -------------------------
nfs_server_machine_region = "us-central1"
nfs_server_machine_zone = "a"
nfs_server_machine_name = "test"
nfs_server_machine_vcpus = 2
nfs_server_machine_memory_in_mb = 4096
nfs_server_boot_disk_image = "ubuntu_1604"
nfs_server_boot_disk_size = 50
nfs_server_boot_disk_type = "hdd"
nfs_server_network = "default"
nfs_server_sa_scopes = []
nfs_server_fileshare_name = "test"
# -----------------------------------------------------------------

# -------------------- GKE CLUSTER SETTINGS ------------------------
gke_cluster_name = "airflow-cluster"
gke_cluster_location = "us-central1-a"
# -----------------------------------------------------------------

# --------------------- CLOUD SQL SETTINGS ------------------------
cloud_sql_name = ""
cloud_sql_database_version = ""
cloud_sql_region = ""
cloud_sql_settings_tier = ""
cloud_sql_settings_disk_size = ""
cloud_sql_settings_disk_autoresize = ""
cloud_sql_user_name = ""
cloud_sql_user_password = ""
# ----------------------------------------------------------------

# --------------------- MEMORYSTORE SETTINGS ---------------------
memorystore_instance_name = ""
memorystore_instance_memory_size_gb = ""
memorystore_redis_version = ""
memorystore_display_name = ""
memorystore_tier = "basic"
memorystore_location_id = ""
memorystore_alternative_location_id = ""
# ----------------------------------------------------------------