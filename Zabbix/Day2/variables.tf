// ssh variables
variable "ssh_user" {
    type        = string
    default     = "centos"
    description = "ssh user name"
}

variable "ssh_key" {
    type        = string
    default     = "~/.ssh/id_rsa.pub"
    description = "ssh user key"
}
// public variable
variable "project" {
    type        = string
    default     = "devopslab2020-288208"
    description = "project name"
}

variable "region" {
    type        = string
    default     = "us-central1"
    description = "project region"
}

variable "zone" {
    type        = string
    default     = "us-central1-c"
    description = "project zone"
}
variable "name" {
    type        = string
    default     = "dmezhva"
    description = "student name"
}

// creating of vpc
variable "vpc_zabbix_auto_subnetworks" {
    type        = bool
    default     = false
    description = "auto creating of default subnetworks for vpc_zabbix"
}

// creating of subnetwork
variable "subnetwork_zabbix_ip_cidr_range" {
    type        = string
    default     = "10.3.1.0/24"
    description = "ip range for public subnetwork"
}

// creating static ip for virtual machine (zabbix server)
variable "static_ip_vm1_address_type" {
    type = string
    default = "INTERNAL"
    description = "type of static ip address for virtual machine"
}

variable "static_ip_vm1_address" {
    type = string
    default = "10.3.1.150"
    description = "static ip for virtual machine"
}

// creating of virtual machine (zabbix server)
variable "vm1_machine_type" {
    type        = string
    default     = "custom-1-4608"
    description = "custom machine type for virtual machine"
}

variable "vm1_tags" {
    type        = list
    default     = ["vm1"]
    description = "virtual machine tags"
}

variable "vm1_image" {
    type        = string
    default     = "centos-cloud/centos-7"
    description = "image for creating virtual machine"
}

// creating of virtual machine (zabbix client)
variable "vm2_machine_type" {
    type        = string
    default     = "custom-1-4608"
    description = "custom machine type for virtual machine"
}

variable "vm2_tags" {
    type        = list
    default     = ["vm2"]
    description = "virtual machine tags"
}

variable "vm2_image" {
    type        = string
    default     = "centos-cloud/centos-7"
    description = "image for creating virtual machine"
}

//creating firewall rule for zabbix server
variable "firewall_zabbix_server_protocol" {
    type        = string
    default     = "tcp"
    description = "firewall protocol"
}

variable "firewall_zabbix_server_ports" {
    type        = list
    default     = ["22", "80", "10050"]
    description = "firewall port"
}
variable "firewall_zabbix_server_source_ranges" {
    type = list
    default = ["0.0.0.0/0"]
    description = "source range from the Internet to virtual machine"
}

//creating firewall rule for zabbix client
variable "firewall_tomcat_protocol" {
    type        = string
    default     = "tcp"
    description = "firewall protocol"
}

variable "firewall_tomcat_ports" {
    type        = list
    default     = ["22", "8080", "10051"]
    description = "firewall port"
}
variable "firewall_tomcat_source_ranges" {
    type = list
    default = ["0.0.0.0/0"]
    description = "source range from the Internet to virtual machine"
}