provider "google" {
  credentials             = file("terraform_admin.json")
  project                 = var.project
  region                  = var.region
  zone 		                = var.zone
}

resource "google_compute_network" "vpc_datadog" {
  name                    = "${var.name}-datadog-vpc"
  auto_create_subnetworks = var.vpc_datadog_auto_subnetworks
}

resource "google_compute_subnetwork" "subnetwork_datadog" {
  name                    = "${var.name}-subnetwork-datadog"
  ip_cidr_range           = var.subnetwork_datadog_ip_cidr_range
  network                 = google_compute_network.vpc_datadog.id
}

resource "google_compute_instance" "vm1" {
  name                    = "${var.name}-datadog"
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
    network               = google_compute_network.vpc_datadog.name
    subnetwork            = google_compute_subnetwork.subnetwork_datadog.name

    access_config {
      // Ephemeral IP
    }
  }
  metadata_startup_script = templatefile("datadog_client.sh", {DD_API_KEY = "${var.DD_API_KEY}", site = "${var.site}"})
}

resource "google_compute_firewall" "firewall_datadog" {
  name                    = "${var.name}-firewall-datadog"
  network                 = google_compute_network.vpc_datadog.name
  source_ranges           = var.firewall_datadog_source_ranges

  allow {
    protocol              = var.firewall_datadog_protocol
    ports                 = var.firewall_datadog_ports
  }

  source_tags             = var.vm1_tags
}

# Configure the Datadog provider
provider "datadog" {
  api_key                 = var.DD_API_KEY
  app_key                 = var.DD_APP_KEY
}

# Create a new monitor
resource "datadog_monitor" "cpumonitor" {
  name                    = "cpu monitor ${google_compute_instance.vm1.name}"
  type                    = var.cpumonitor_type 
  message                 = var.cpumonitor_message
  query                   = "avg(last_1m):avg:system.cpu.user{instance-id:${google_compute_instance.vm1.instance_id}} > 80"
}