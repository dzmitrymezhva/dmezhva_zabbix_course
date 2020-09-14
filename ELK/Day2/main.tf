provider "google" {
  credentials             = file("terraform_admin.json")
  project                 = var.project
  region                  = var.region
  zone 		                = var.zone
}

resource "google_compute_network" "vpc_elk" {
  name                    = "${var.name}-elk-vpc"
  auto_create_subnetworks = var.vpc_elk_auto_subnetworks
}

resource "google_compute_subnetwork" "subnetwork_elk" {
  name                    = "${var.name}-subnetwork-elk"
  ip_cidr_range           = var.subnetwork_elk_ip_cidr_range
  network                 = google_compute_network.vpc_elk.id
}

resource "google_compute_address" "static_ip_elk_server" {
  name         = "${var.name}-static-ip-elk-server"
  subnetwork   = google_compute_subnetwork.subnetwork_elk.id
  address_type = var.static_ip_address_type
  address      = var.static_ip_address
}

resource "google_compute_instance" "vm1" {
  name                    = "${var.name}-elk-server"
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
    network               = google_compute_network.vpc_elk.name
    subnetwork            = google_compute_subnetwork.subnetwork_elk.name
    network_ip            = google_compute_address.static_ip_elk_server.address
    
    access_config {
      // Ephemeral IP
    }
  }
  metadata_startup_script = file("server.sh")
}

resource "google_compute_instance" "vm2" {
  name                    = "${var.name}-elk-client"
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
    network               = google_compute_network.vpc_elk.name
    subnetwork            = google_compute_subnetwork.subnetwork_elk.name
  
    access_config {
      // Ephemeral IP
    }
  }    
  metadata_startup_script = templatefile("client.sh", {staticIP = "${var.static_ip_address}"})
}

resource "google_compute_firewall" "firewall_elk_server" {
  name                    = "${var.name}-firewall-elk-server"
  network                 = google_compute_network.vpc_elk.name
  source_ranges           = var.firewall_elk_server_source_ranges

  allow {
    protocol              = var.firewall_elk_server_protocol
    ports                 = var.firewall_elk_server_ports
  }

  source_tags             = var.firewall_elk_server_source_tags
}


resource "google_compute_firewall" "firewall_elk_client" {
  name                    = "${var.name}-firewall-elk-client"
  network                 = google_compute_network.vpc_elk.name
  source_ranges           = var.firewall_elk_client_source_ranges

  allow {
    protocol              = var.firewall_elk_client_protocol
    ports                 = var.firewall_elk_client_ports
  }

  source_tags             = var.firewall_elk_client_source_tags
}