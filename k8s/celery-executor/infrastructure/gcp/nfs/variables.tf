locals {
  machine_type_fmt = "custom-%d-%d"
  zone_fmt = "%s-%s"
  nfs_script_file = "${path.module}/nfs.sh"
  placeholder_fileshare_name = "fileshare_name"
  placeholder_network = "network"
}

variable "nfs_server_machine_name" {type = string}
variable "nfs_server_machine_region" {type = string}
variable "nfs_server_machine_zone" {type = string}
variable "nfs_server_machine_vcpus" {type = number}
variable "nfs_server_machine_memory_in_mb" {type = number}
variable "nfs_server_boot_disk_image" {type = string}
variable "nfs_server_boot_disk_size" {type = number}
variable "nfs_server_boot_disk_type" {type = string}
variable "nfs_server_network" {type = string}
variable "nfs_server_network_cidr" {type = string}
variable "nfs_server_sa_scopes" {type = list(string)}
variable "nfs_server_fileshare_name" {type = string}