resource "google_sql_database_instance" "cloud_sql_instance" {
  name = var.cloud_sql_name
  database_version = var.cloud_sql_database_version
  region = var.cloud_sql_region

  settings {
    tier = var.cloud_sql_settings_tier
    disk_size = var.cloud_sql_settings_disk_size
    disk_type = var.cloud_sql_settings_disk_type
    disk_autoresize = var.cloud_sql_settings_disk_autoresize
  }
}

resource "google_sql_user" "cloud_sql_user" {
  instance = google_sql_database_instance.cloud_sql_instance.name
  name = var.cloud_sql_user_name
  password = var.cloud_sql_user_password
}