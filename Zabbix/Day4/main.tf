provider "google" {
  credentials             = file("terraform_admin.json")
  project                 = var.project
  region                  = var.region
  zone 		                = var.zone
}

resource "google_compute_network" "vpc_prometheus" {
  name                    = "${var.name}-prometheus-vpc"
  auto_create_subnetworks = var.vpc_prometheus_auto_subnetworks
}

resource "google_compute_subnetwork" "subnetwork_prometheus" {
  name                    = "${var.name}-subnetwork-prometheus"
  ip_cidr_range           = var.subnetwork_prometheus_ip_cidr_range
  network                 = google_compute_network.vpc_prometheus.id
}

resource "google_compute_address" "static_ip_vm1" {
  name = "${var.name}-static-ip-vm1"
}

resource "google_compute_address" "static_ip_vm2" {
  name                    = "${var.name}-static-ip-vm2"
  subnetwork              = google_compute_subnetwork.subnetwork_prometheus.id
  address_type            = var.static_ip_vm2_address_type
  address                 = var.static_ip_vm2_address
}

resource "google_compute_instance" "vm1" {
  name                    = "${var.name}-prometheus"
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
    network               = google_compute_network.vpc_prometheus.name
    subnetwork            = google_compute_subnetwork.subnetwork_prometheus.name    

    access_config {
      nat_ip = google_compute_address.static_ip_vm1.address
    }
  }
  metadata_startup_script = templatefile("prometheus.sh", {email_pass = "${var.email_pass}", 
  email = "${var.email}", smtp_server = "${var.smtp_server}", 
  node_exporter_ip = google_compute_address.static_ip_vm2.address,
  prometheus_ip = google_compute_address.static_ip_vm1.address})
}

resource "google_compute_instance" "vm2" {
  name                    = "${var.name}-node"
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
    network               = google_compute_network.vpc_prometheus.name
    subnetwork            = google_compute_subnetwork.subnetwork_prometheus.name
    network_ip            = google_compute_address.static_ip_vm2.address

    access_config {
      // Ephemeral IP
    }
  }    
  metadata_startup_script = file("node_exporter.sh")
}

resource "google_compute_firewall" "firewall_prometheus" {
  name                    = "${var.name}-firewall-prometheus"
  network                 = google_compute_network.vpc_prometheus.name
  source_ranges           = var.firewall_prometheus_source_ranges

  allow {
    protocol              = var.firewall_prometheus_protocol
    ports                 = var.firewall_prometheus_ports
  }

  source_tags             = var.vm1_tags
}


resource "google_compute_firewall" "firewall_node" {
  name                    = "${var.name}-firewall-node"
  network                 = google_compute_network.vpc_prometheus.name
  source_ranges           = var.firewall_node_source_ranges

  allow {
    protocol              = var.firewall_node_protocol
    ports                 = var.firewall_node_ports
  }

  source_tags             = var.vm2_tags
}