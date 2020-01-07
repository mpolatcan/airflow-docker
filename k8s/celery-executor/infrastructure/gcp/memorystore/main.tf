resource "google_redis_instance" "memorystore_instance" {
  name = var.memorystore_instance_name
  memory_size_gb = var.memorystore_instance_memory_size_gb
  redis_version = var.memorystore_redis_version
  display_name = var.memorystore_display_name
  tier = var.memorystore_tier
  location_id = var.memorystore_location_id
  alternative_location_id = var.memorystore_alternative_location_id
}