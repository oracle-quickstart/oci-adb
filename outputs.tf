## Copyright © 2020, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

output "adb_database" {
  value = {
    adb_database_id    = oci_database_autonomous_database.adb_database.id
    adb_wallet_content = oci_database_autonomous_database_wallet.adb_database_wallet.content
    adb_nsg_id         = (!var.use_existing_vcn && var.adb_private_endpoint) ? oci_core_network_security_group.adb_nsg[0].id : var.adb_nsg_id
  }
}



