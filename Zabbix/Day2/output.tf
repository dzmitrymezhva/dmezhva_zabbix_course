output "ZABBIX" {
  value = "(WebUI Username - Admin, WebUI Password - zabbix) http://${google_compute_instance.vm1.network_interface.0.access_config.0.nat_ip}/zabbix/"
}

output "TOMCAT" {
  value = "http://${google_compute_instance.vm2.network_interface.0.access_config.0.nat_ip}:8080/SampleWebApp/SnoopServlet/"
}