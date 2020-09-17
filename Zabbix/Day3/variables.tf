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

variable "DD_API_KEY" {
    type        = string
    description = "datadog api key"
}

variable "DD_APP_KEY" {
    type = string
    description = "datadog app key"
}

variable "site" {
    type        = string
    default     = "epam.com"
    description = "name of web site for metric"
}

// creating of vpc
variable "vpc_datadog_auto_subnetworks" {
    type        = bool
    default     = false
    description = "auto creating of default subnetworks for vpc_datadog"
}

// creating of subnetwork
variable "subnetwork_datadog_ip_cidr_range" {
    type        = string
    default     = "10.3.1.0/24"
    description = "ip range for subnetwork"
}

// creating of virtual machine (datadog)
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

//creating firewall rule for datadog
variable "firewall_datadog_protocol" {
    type        = string
    default     = "tcp"
    description = "firewall protocol"
}

variable "firewall_datadog_ports" {
    type        = list
    default     = ["22"]
    description = "firewall port"
}
variable "firewall_datadog_source_ranges" {
    type        = list
    default     = ["0.0.0.0/0"]
    description = "source range from the Internet to virtual machine"
}

// Creating datadog monitor
variable "cpumonitor_type" {
    type        = string
    default     = "metric alert"
    description = "type of datadog monitor"
}

variable "cpumonitor_message" {
    type        = string
    default     = "CPU usage alert! @dzmitry.mezhva@gmail.com"
    description = "alert message for monitor"
}