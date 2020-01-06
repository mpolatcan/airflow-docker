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
cloud_sql_name = "test"
cloud_sql_region = "us-central1-a"
# ----------------------------------------------------------------

# --------------------- MEMORYSTORE SETTINGS ---------------------
memorystore_instance_name = "test"
memorystore_location_id = "us-central1"
# ----------------------------------------------------------------