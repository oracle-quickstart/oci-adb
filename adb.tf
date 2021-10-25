## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

locals {
  adb_nsg_id    = (!var.use_existing_vcn && var.adb_private_endpoint) ? oci_core_network_security_group.adb_nsg[0].id : var.adb_nsg_id
  adb_subnet_id = (!var.use_existing_vcn && var.adb_private_endpoint) ? oci_core_subnet.adb_subnet[0].id : var.adb_subnet_id
}

resource "oci_database_autonomous_database" "adb_database" {
  admin_password           = var.adb_password
  compartment_id           = var.compartment_ocid
  cpu_core_count           = var.adb_database_cpu_core_count
  data_storage_size_in_tbs = var.adb_database_data_storage_size_in_tbs
  db_name                  = var.adb_database_db_name
  db_version               = var.adb_database_db_version
  data_safe_status         = var.adb_data_safe_status
  db_workload              = var.adb_database_db_workload
  display_name             = var.adb_database_display_name
  freeform_tags            = var.adb_database_freeform_tags
  license_model            = var.adb_database_license_model
  is_free_tier             = var.adb_free_tier
  is_data_guard_enabled    = var.is_data_guard_enabled
  is_auto_scaling_enabled  = var.is_auto_scaling_enabled
  whitelisted_ips          = var.adb_private_endpoint ? null : var.whitelisted_ips
  nsg_ids                  = var.adb_private_endpoint ? [local.adb_nsg_id] : null
  private_endpoint_label   = var.adb_private_endpoint ? var.adb_private_endpoint_label : null
  subnet_id                = var.adb_private_endpoint ? local.adb_subnet_id : null
  defined_tags             = var.defined_tags
  lifecycle {
    ignore_changes = [defined_tags["Oracle-Tags.CreatedBy"], defined_tags["Oracle-Tags.CreatedOn"]]
  }
}

resource "random_password" "wallet_password" {
  length           = var.adb_wallet_password_length
  special          = var.adb_wallet_password_specials
  min_numeric      = var.adb_wallet_password_min_numeric
  override_special = var.adb_wallet_password_override_special
}

resource "oci_database_autonomous_database_wallet" "adb_database_wallet" {
  autonomous_database_id = oci_database_autonomous_database.adb_database.id
  password               = random_password.wallet_password.result
  base64_encode_content  = "true"
}
