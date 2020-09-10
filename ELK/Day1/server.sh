#! /bin/bash

## Install Elasticsearch with RPM
# Import the Elasticsearch PGP Key
sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch

# Add Elasticsearch repository
sudo cat > /etc/yum.repos.d/lasticsearch.repo << EOF
[elasticsearch]
name=Elasticsearch repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=0
autorefresh=1
type=rpm-md
EOF

# Installing Elasticsearch from the RPM repository
sudo yum install -y --enablerepo=elasticsearch elasticsearch

# Change Elasticsearch config file
sudo echo 'http.host: 0.0.0.0' >> /etc/elasticsearch/elasticsearch.yml

# Running Elasticsearch with systemd
sudo systemctl daemon-reload
sudo systemctl enable elasticsearch
sudo systemctl start elasticsearch



## Install Kibana with RPM
# Add Kibana repository
sudo cat > /etc/yum.repos.d/kibana.repo << EOF
[kibana-7.x]
name=Kibana repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF

# Installing Kibana from the RPM repository
sudo yum install -y kibana

# Change Elasticsearch config file
sudo echo 'server.host: "0.0.0.0"' >> /etc/kibana/kibana.yml

# Running Kibana with systemd
sudo systemctl daemon-reload
sudo systemctl enable kibana
sudo systemctl start kibana