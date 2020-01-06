resource "google_compute_instance" "nfs_server" {
  machine_type = format(
    local.machine_type_fmt,
    var.nfs_server_machine_vcpus,
    var.nfs_server_machine_memory_in_mb
  )
  name = var.nfs_server_machine_name
  zone = format(
    local.zone_fmt,
    var.nfs_server_machine_region,
    var.nfs_server_machine_zone
  )

  boot_disk {
    initialize_params {
      image = var.nfs_server_boot_disk_image
      size = var.nfs_server_boot_disk_size
      type = var.nfs_server_boot_disk_type
    }
  }

  network_interface {
    network = var.nfs_server_network

    access_config {
        // Public IP
    }
  }

  metadata_startup_script = replace(
      replace(
        file(local.nfs_script_file),
        local.placeholder_fileshare_name,
        var.nfs_server_fileshare_name
      ),
      local.placeholder_network,
      var.nfs_server_network_cidr
  )

  service_account {
    scopes = var.nfs_server_sa_scopes
  }

  allow_stopping_for_update = true
}