output "autonomous_database_id" {
  description = "OCID of the Autonomous Database"
  value       = oci_database_autonomous_database.main.id
}

output "autonomous_database_name" {
  description = "Display name of the Autonomous Database"
  value       = oci_database_autonomous_database.main.display_name
}

output "db_workload" {
  description = "Workload type of the Autonomous Database (OLTP, DW, AJD, APEX)"
  value       = oci_database_autonomous_database.main.db_workload
}

output "state" {
  description = "Lifecycle state of the Autonomous Database"
  value       = oci_database_autonomous_database.main.state
}

output "connection_strings" {
  description = "Connection strings for the Autonomous Database"
  value       = oci_database_autonomous_database.main.connection_strings
}

output "service_console_url" {
  description = "Service console URL for the Autonomous Database"
  value       = oci_database_autonomous_database.main.service_console_url
}

output "is_free_tier" {
  description = "Confirms whether the always-free tier is enabled"
  value       = oci_database_autonomous_database.main.is_free_tier
}
