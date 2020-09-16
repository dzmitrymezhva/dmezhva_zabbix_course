#! /bin/bash

##Selinux
# Disable Temporarily (without reboot)
sudo setenforce 0

# Disable Permanently (after reboot)
sudo sed -i "s/enforcing/disabled/g" /etc/selinux/config

## Configure firewall
sudo firewall-cmd --add-port={10050/tcp,8080/tcp} --permanent
sudo firewall-cmd --reload

## Installing and configuring Zabbix Client
# Install Zabbix Repo
sudo rpm -Uvh https://repo.zabbix.com/zabbix/5.0/rhel/7/x86_64/zabbix-release-5.0-1.el7.noarch.rpm
sudo yum clean all

# Install Zabbix DB package
sudo yum install -y zabbix-agent

# Zabbix Agent Configuration
sudo sed -i.backup "/^Server=*/s/127.0.0.1/${staticIP}/; /^# ListenPort=*/s/^# //; /^Hostname=/s/server/client/; /^ServerActive=*/s/127.0.0.1/${staticIP}/; s/^# HostMetadataItem=/HostMetadataItem=system.uname/" /etc/zabbix/zabbix_agentd.conf

# Start Zabbix and add to auto startup
sudo systemctl start zabbix-agent
sudo systemctl enable zabbix-agent

## Installing and configuring Tomcat server
# Install Tomcat server
sudo yum install -y tomcat tomcat-webapps tomcat-admin-webapps tomcat-docs-webapp tomcat-javadoc
sudo systemctl start tomcat
sudo systemctl enable tomcat

# Install wget
sudo yum install -y wget

# Deploy app
sudo wget -P /usr/share/tomcat/webapps/ https://github.com/AKSarav/SampleWebApp/raw/master/dist/SampleWebApp.war

# Set permissions for log folder
sudo chmod 0777 /var/log/tomcat -R