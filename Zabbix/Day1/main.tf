provider "google" {
  credentials             = file("terraform_admin.json")
  project                 = var.project
  region                  = var.region
  zone 		                = var.zone
}

resource "google_compute_network" "vpc_zabbix" {
  name                    = "${var.name}-zabbix-vpc"
  auto_create_subnetworks = var.vpc_zabbix_auto_subnetworks
}

resource "google_compute_subnetwork" "subnetwork_zabbix" {
  name                    = "${var.name}-subnetwork-zabbix"
  ip_cidr_range           = var.subnetwork_zabbix_ip_cidr_range
  network                 = google_compute_network.vpc_zabbix.id
}

resource "google_compute_address" "static_ip_vm1" {
  name                    = "${var.name}-static-ip-vm1"
  subnetwork              = google_compute_subnetwork.subnetwork_zabbix.id
  address_type            = var.static_ip_vm1_address_type
  address                 = var.static_ip_vm1_address
}

resource "google_compute_instance" "vm1" {
  name                    = "${var.name}-zabbix-server"
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
    network               = google_compute_network.vpc_zabbix.name
    subnetwork            = google_compute_subnetwork.subnetwork_zabbix.name
    network_ip            = google_compute_address.static_ip_vm1.address

    access_config {
      // Ephemeral IP
    }
  }
  metadata_startup_script = file("zabbix_server.sh")
}

resource "google_compute_instance" "vm2" {
  name                    = "${var.name}-zabbix-client"
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
    network               = google_compute_network.vpc_zabbix.name
    subnetwork            = google_compute_subnetwork.subnetwork_zabbix.name
  
    access_config {
      // Ephemeral IP
    }
  }    
  metadata_startup_script = templatefile("zabbix_client.sh", {staticIP = "${var.static_ip_vm1_address}"})
}

resource "google_compute_firewall" "firewall_zabbix_server" {
  name                    = "${var.name}-firewall-zabbix-server"
  network                 = google_compute_network.vpc_zabbix.name
  source_ranges           = var.firewall_zabbix_server_source_ranges

  allow {
    protocol              = var.firewall_zabbix_server_protocol
    ports                 = var.firewall_zabbix_server_ports
  }

  source_tags             = var.vm1_tags
}


resource "google_compute_firewall" "firewall_zabbix_client" {
  name                    = "${var.name}-firewall-zabbix-client"
  network                 = google_compute_network.vpc_zabbix.name
  source_ranges           = var.firewall_zabbix_client_source_ranges

  allow {
    protocol              = var.firewall_zabbix_client_protocol
    ports                 = var.firewall_zabbix_client_ports
  }

  source_tags             = var.vm2_tags
}