## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

module "oci-adb" {
  source                                = "github.com/oracle-quickstart/oci-adb"
  adb_database_db_name                  = "myadw"
  adb_database_display_name             = "myadw"
  adb_password                          = var.adb_password
  adb_database_db_workload              = "DW" # Autonomous Warehouse (ADW)
  adb_free_tier                         = false
  adb_database_cpu_core_count           = 2
  adb_database_data_storage_size_in_tbs = 10
  compartment_ocid                      = var.compartment_ocid
  use_existing_vcn                      = true
  adb_private_endpoint                  = true
  adb_private_endpoint_label            = "myadwpe"
  vcn_id                                = oci_core_vcn.my_vcn.id
  adb_subnet_id                         = oci_core_subnet.my_private_subnet.id
  adb_nsg_id                            = oci_core_network_security_group.my_nsg.id
}

