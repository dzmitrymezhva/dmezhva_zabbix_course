provider "google" {
  credentials             = file("terraform_admin.json")
  project                 = var.project
  region                  = var.region
  zone 		                = var.zone
}

resource "google_compute_network" "vpc_ldap" {
  name                    = "${var.name}-ldap-vpc"
  auto_create_subnetworks = var.vpc_ldap_auto_subnetworks
}

resource "google_compute_subnetwork" "subnetwork_privat" {
  name                    = "${var.name}-subnetwork-privat"
  ip_cidr_range           = var.subnetwork_privat_ip_cidr_range
  network                 = google_compute_network.vpc_ldap.id
}

resource "google_compute_address" "static_ip_vm1" {
  name                    = "${var.name}-static-ip-vm1"
  subnetwork              = google_compute_subnetwork.subnetwork_privat.id
  address_type            = var.static_ip_vm1_address_type
  address                 = var.static_ip_vm1_address
}

resource "google_compute_instance" "vm1" {
  name                    = "${var.name}-vm1"
  machine_type            = var.vm1_machine_type
  tags                    = var.vm1_tags
  metadata = {
    ssh-keys              = "${var.ssh_user}:${file(var.ssh_key)}"
  }

  boot_disk {
    initialize_params {
      image               = var.vm1_image
    }
  }

  network_interface {
    network               = google_compute_network.vpc_ldap.name
    subnetwork            = google_compute_subnetwork.subnetwork_privat.name
    network_ip            = google_compute_address.static_ip_vm1.address

    access_config {
      // Ephemeral IP
    }
  }
  metadata_startup_script = file("server.sh")
}

resource "google_compute_instance" "vm2" {
  name                    = "${var.name}-vm2"
  machine_type            = var.vm2_machine_type
  tags                    = var.vm2_tags
  metadata = {
    ssh-keys              = "${var.ssh_user}:${file(var.ssh_key)}"
  }

  boot_disk {
    initialize_params {
      image               = var.vm2_image
    }
  }

  network_interface {
    network               = google_compute_network.vpc_ldap.name
    subnetwork            = google_compute_subnetwork.subnetwork_privat.name
  
    access_config {
      // Ephemeral IP
    }
  }    
  metadata_startup_script = file("client.sh")
}

resource "google_compute_firewall" "firewall_ldap_server" {
  name                    = "${var.name}-firewall-ldap-server"
  network                 = google_compute_network.vpc_ldap.name
  source_ranges           = var.firewall_ldap_server_source_ranges

  allow {
    protocol              = var.firewall_ldap_server_protocol
    ports                 = var.firewall_ldap_server_ports
  }

  source_tags             = var.firewall_ldap_server_source_tags
}