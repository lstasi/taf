output "bucket_name" {
  description = "Name of the Object Storage bucket"
  value       = oci_objectstorage_bucket.main.name
}

output "bucket_id" {
  description = "OCID-like identifier of the bucket"
  value       = oci_objectstorage_bucket.main.id
}

output "namespace" {
  description = "Object Storage namespace"
  value       = data.oci_objectstorage_namespace.ns.namespace
}

output "storage_tier" {
  description = "Storage tier of the bucket"
  value       = oci_objectstorage_bucket.main.storage_tier
}

output "bucket_url" {
  description = "Base URL for accessing objects in the bucket via the OCI Object Storage API"
  value       = "https://objectstorage.${var.region}.oraclecloud.com/n/${data.oci_objectstorage_namespace.ns.namespace}/b/${oci_objectstorage_bucket.main.name}/o"
}
