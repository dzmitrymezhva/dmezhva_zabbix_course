#! /bin/bash

## install node exporter
# install wget package for downloading node exporter package
sudo yum install -y wget

# download node exporter package 
sudo wget https://github.com/prometheus/node_exporter/releases/download/v1.0.1/node_exporter-1.0.1.linux-amd64.tar.gz

# extract the downloaded package
sudo tar -C /usr/local/bin/ -xzf node_exporter-* --strip-components 1

# create a service file for the node exporter
cat << EOF | sudo tee /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=root
Group=root
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

# reload system daemon
sudo systemctl daemon-reload

# enable node exporter on system boot
sudo systemctl enable node_exporter

# start node exporter service
sudo systemctl start node_exporter

# add a firewall rule to allow node exporter
sudo firewall-cmd --zone=public --add-port=9100/tcp --permanent

# reload firewall service
sudo systemctl restart firewalld