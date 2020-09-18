output "blackbox" {
  value = "http://${google_compute_instance.vm1.network_interface.0.access_config.0.nat_ip}:9115"
}

output "alertmanager" {
  value = "http://${google_compute_instance.vm1.network_interface.0.access_config.0.nat_ip}:9093"
}

output "grafana" {
  value = "http://${google_compute_instance.vm1.network_interface.0.access_config.0.nat_ip}:3000"
}

output "prometheus" {
  value = "http://${google_compute_instance.vm1.network_interface.0.access_config.0.nat_ip}:9090/targets"
}