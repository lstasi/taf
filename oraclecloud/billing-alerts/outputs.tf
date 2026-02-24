output "budget_id" {
  description = "OCID of the OCI Budget"
  value       = oci_budget_budget.monthly_budget.id
}

output "budget_name" {
  description = "Name of the OCI Budget"
  value       = oci_budget_budget.monthly_budget.display_name
}

output "notification_topic_id" {
  description = "OCID of the Notifications topic"
  value       = oci_ons_notification_topic.billing_topic.id
}

output "notification_topic_name" {
  description = "Name of the Notifications topic"
  value       = oci_ons_notification_topic.billing_topic.name
}
