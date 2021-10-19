## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_core_vcn" "my_vcn" {
  cidr_block     = "192.168.0.0/16"
  compartment_id = var.compartment_ocid
  display_name   = "my_vcn"
  dns_label      = "myvcn"
}

resource "oci_core_service_gateway" "my_sg" {
  compartment_id = var.compartment_ocid
  display_name   = "my_sg"
  vcn_id         = oci_core_vcn.my_vcn.id
  services {
    service_id = lookup(data.oci_core_services.AllOCIServices.services[0], "id")
  }
}

resource "oci_core_nat_gateway" "my_natgw" {
  compartment_id = var.compartment_ocid
  display_name   = "my_natgw"
  vcn_id         = oci_core_vcn.my_vcn.id
}

resource "oci_core_route_table" "my_rt_via_natgw_and_sg" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.my_vcn.id
  display_name   = "my_rt_via_natgw"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.my_natgw.id
  }

  route_rules {
    destination       = lookup(data.oci_core_services.AllOCIServices.services[0], "cidr_block")
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.my_sg.id
  }
}

resource "oci_core_internet_gateway" "my_igw" {
  compartment_id = var.compartment_ocid
  display_name   = "my_igw"
  vcn_id         = oci_core_vcn.my_vcn.id
}

resource "oci_core_route_table" "my_rt_via_igw" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.my_vcn.id
  display_name   = "my_rt_via_igw"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.my_igw.id
  }
}

resource "oci_core_network_security_group" "my_nsg" {
  compartment_id = var.compartment_ocid
  display_name   = "my_nsg"
  vcn_id         = oci_core_vcn.my_vcn.id
}

resource "oci_core_network_security_group_security_rule" "my_nsg_egress_group_sec_rule" {
  network_security_group_id = oci_core_network_security_group.my_nsg.id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = "192.168.0.0/16"
  destination_type          = "CIDR_BLOCK"
}

resource "oci_core_network_security_group_security_rule" "my_nsg_ingress_group_sec_rule" {
  network_security_group_id = oci_core_network_security_group.my_nsg.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "192.168.0.0/16"
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = 1522
      min = 1522
    }
  }
}

resource "oci_core_subnet" "my_public_subnet" {
  cidr_block                 = "192.168.1.0/24"
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.my_vcn.id
  display_name               = "my_public_subnet"
  dns_label                  = "mynet1"
  security_list_ids          = [oci_core_vcn.my_vcn.default_security_list_id]
  route_table_id             = oci_core_route_table.my_rt_via_igw.id
  prohibit_public_ip_on_vnic = false
}

resource "oci_core_subnet" "my_private_subnet" {
  cidr_block                 = "192.168.2.0/24"
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.my_vcn.id
  display_name               = "my_private_subnet"
  dns_label                  = "mynet2"
  security_list_ids          = [oci_core_vcn.my_vcn.default_security_list_id]
  route_table_id             = oci_core_route_table.my_rt_via_natgw_and_sg.id
  prohibit_public_ip_on_vnic = true
}



