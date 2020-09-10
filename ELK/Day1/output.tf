output "tomcat" {
  value = "http://${google_compute_instance.vm2.network_interface.0.access_config.0.nat_ip}:8080"
}

output "kibana" {
  value = "http://${google_compute_instance.vm1.network_interface.0.access_config.0.nat_ip}:5601"
}

output "elasticsearch" {
  value = "http://${google_compute_instance.vm1.network_interface.0.access_config.0.nat_ip}:9200/_cluster/health/?pretty"
}