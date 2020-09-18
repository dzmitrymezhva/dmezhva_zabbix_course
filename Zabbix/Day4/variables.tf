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

// mail variables
variable "email" {
    type        = string
    default     = "dzmitry.mezhva@gmail.com"
    description = "my email"
}

variable "email_pass" {
    type        = string
    description = "email pass from dzmitry.mezhva@gmail.com for alert"
}

variable "smtp_server" {
    type        = string
    default     = "smtp.gmail.com:587"
    description = "smtp sever for alert"
}

// creating of vpc
variable "vpc_prometheus_auto_subnetworks" {
    type        = bool
    default     = false
    description = "auto creating of default subnetworks for vpc_prometheus"
}

// creating of subnetwork
variable "subnetwork_prometheus_ip_cidr_range" {
    type        = string
    default     = "10.0.0.0/24"
    description = "ip range for public subnetwork"
}

// creating static ip for virtual machine (node)
variable "static_ip_vm2_address_type" {
    type = string
    default = "INTERNAL"
    description = "type of static ip address for virtual machine"
}

variable "static_ip_vm2_address" {
    type = string
    default = "10.0.0.123"
    description = "static ip for virtual machine"
}

// creating of virtual machine (prometheus)
variable "vm1_machine_type" {
    type        = string
    default     = "custom-1-4608"
    description = "custom machine type for virtual machine"
}

variable "vm1_tags" {
    type        = list
    default     = ["prometheus"]
    description = "virtual machine tags"
}

variable "vm1_image" {
    type        = string
    default     = "centos-cloud/centos-7"
    description = "image for creating virtual machine"
}

// creating of virtual machine (node)
variable "vm2_machine_type" {
    type        = string
    default     = "custom-1-4608"
    description = "custom machine type for virtual machine"
}

variable "vm2_tags" {
    type        = list
    default     = ["node"]
    description = "virtual machine tags"
}

variable "vm2_image" {
    type        = string
    default     = "centos-cloud/centos-7"
    description = "image for creating virtual machine"
}

//creating firewall rule for prometheus
variable "firewall_prometheus_protocol" {
    type        = string
    default     = "tcp"
    description = "firewall protocol"
}

variable "firewall_prometheus_ports" {
    type        = list
    default     = ["22", "3000", "9090", "9093", "9100", "9115"]
    description = "firewall port"
}
variable "firewall_prometheus_source_ranges" {
    type = list
    default = ["0.0.0.0/0"]
    description = "source range from the Internet to virtual machine"
}

//creating firewall rule for node
variable "firewall_node_protocol" {
    type        = string
    default     = "tcp"
    description = "firewall protocol"
}

variable "firewall_node_ports" {
    type        = list
    default     = ["22", "9100"]
    description = "firewall port"
}
variable "firewall_node_source_ranges" {
    type = list
    default = ["0.0.0.0/0"]
    description = "source range from the Internet to virtual machine"
}