output "LDAPclientSSHpass" {
  value = "ssh ${var.name}@${google_compute_instance.vm2.network_interface.0.access_config.0.nat_ip}"
}

output "LDAPclientSSHkey" {
  value = "ssh ${var.name}@${google_compute_instance.vm2.network_interface.0.access_config.0.nat_ip} -i /path/to/privatekey"
}

output "UILDAP" {
  value = "http://${google_compute_instance.vm1.network_interface.0.access_config.0.nat_ip}/ldapadmin/"
}

output "LDAPserverSSH" {
  value = "ssh ${var.ssh_user}@${google_compute_instance.vm1.network_interface.0.access_config.0.nat_ip}"
}
