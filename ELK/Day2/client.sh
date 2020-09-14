#! /bin/bash

#### ----------==========DAY1==========----------
## Install Tomcat server
sudo yum install -y tomcat tomcat-webapps tomcat-admin-webapps tomcat-docs-webapp tomcat-javadoc
sudo systemctl start tomcat
sudo systemctl enable tomcat

#### ----------==========DAY2==========----------
## Install Logstash with RPM
# Import the Logstash PGP Key
sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch

# Add Logstash repository
sudo cat > /etc/yum.repos.d/logstash.repo << EOF
[logstash-7.x]
name=Elastic repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF

# Installing Logstash from the RPM repository
sudo yum install -y logstash

# Add Logstash repository
sudo cat > /etc/logstash/conf.d/tomcat7.conf << EOF
input {
  file {
    path => "/var/log/tomcat/catalina*"
    start_position => "beginning"
  }
}

output {
  elasticsearch {
    hosts => ["${staticIP}:9200"]
  }
  stdout { codec => rubydebug }
}
EOF

# Start logstash server
sudo systemctl restart logstash

# Change rules for tomcat log folder
sudo chmod 0775 /var/log/tomcat

## Install wget
sudo yum install -y wget

## Create content log
sudo wget -P /usr/share/tomcat/webapps/ https://github.com/AKSarav/SampleWebApp/raw/master/dist/SampleWebApp.war
sudo sleep 20
sudo rm -f /usr/share/tomcat/webapps/SampleWebApp.war
sudo sleep 20
sudo wget -P /usr/share/tomcat/webapps/ https://github.com/AKSarav/SampleWebApp/raw/master/dist/SampleWebApp.war