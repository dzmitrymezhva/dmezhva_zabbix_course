#! /bin/bash

##Selinux
# Disable Temporarily (without reboot)
sudo setenforce 0

# Disable Permanently (after reboot)
sudo sed -i "s/enforcing/disabled/g" /etc/selinux/config

## Configure firewall
sudo firewall-cmd --add-port={10051/tcp,} --permanent
sudo firewall-cmd --reload

## Installing and configuring MySQL DB (MariaDB)
# Install mysql server (official web site)
sudo yum install -y wget
sudo wget https://downloads.mariadb.com/MariaDB/mariadb_repo_setup
sudo chmod +x mariadb_repo_setup
sudo ./mariadb_repo_setup
sudo yum install -y MariaDB-server

# Starting and enabling mysqld service
sudo systemctl start mariadb
sudo systemctl enable mariadb
sudo sleep 10s

# Creating initial database
export zabbix_db_pass="dmezhva"
export zabbix_db_name="zabbix_db"
export zabbix_db_user="zabbix_user"
sudo mysql -uroot <<MYSQL_SCRIPT
create database $zabbix_db_name character set utf8 collate utf8_bin;
create user $zabbix_db_user@localhost identified by '${zabbix_db_pass}';
grant all privileges on $zabbix_db_name.* to $zabbix_db_user@localhost;
FLUSH PRIVILEGES;
MYSQL_SCRIPT

## Installing and configuring Zabbix Server
# Install Zabbix Repo
sudo rpm -Uvh https://repo.zabbix.com/zabbix/5.0/rhel/7/x86_64/zabbix-release-5.0-1.el7.noarch.rpm
sudo yum clean all

# Install Zabbix DB package
sudo yum install -y zabbix-server-mysql

# Import initial schema and data
sudo zcat /usr/share/doc/zabbix-server-mysql*/create.sql.gz | mysql --user=$zabbix_db_user $zabbix_db_name --password=$zabbix_db_pass

# Database configuration for Zabbix server
sudo sed -i.backup "s/^# DBPassword=/DBPassword=$zabbix_db_pass/; s/^# DBHost=localhost/DBHost=localhost/; s/^DBName=zabbix/DBName=$zabbix_db_name/; s/^DBUser=zabbix/DBUser=$zabbix_db_user/" /etc/zabbix/zabbix_server.conf

# Starting Zabbix server process
sudo systemctl start zabbix-server

## Front-end Installation and Configuration
# Enable Red Hat Software Collections
sudo yum install -y centos-release-scl
sudo sed -i.backup "s/^enabled=0/enabled=1/" /etc/yum.repos.d/zabbix.repo

# Install Zabbix frontend package
sudo yum install -y zabbix-web-mysql-scl zabbix-apache-conf-scl

# Configuring PHP settings
sudo sed -i.backup "s|^; ||; s|Riga|Minsk|" /etc/opt/rh/rh-php72/php-fpm.d/zabbix.conf

# Starting Front-end
sudo systemctl start httpd

## Restart services
sudo systemctl restart zabbix-server httpd rh-php72-php-fpm

## Add services to auto startup
sudo systemctl enable zabbix-server httpd rh-php72-php-fpm

## Configure UI
# Create file manually for zabbix servrer
sudo cat > ~/zabbix.conf.php << 'EOF'
<?php
// Zabbix GUI configuration file.

$DB['TYPE']                     = 'MYSQL';
$DB['SERVER']                   = 'localhost';
$DB['PORT']                     = '3306';
$DB['DATABASE']                 = 'zabbix_db';
$DB['USER']                     = 'zabbix_user';
$DB['PASSWORD']                 = 'dmezhva';

// Schema name. Used for PostgreSQL.
$DB['SCHEMA']                   = '';

// Used for TLS connection.
$DB['ENCRYPTION']               = false;
$DB['KEY_FILE']                 = '';
$DB['CERT_FILE']                = '';
$DB['CA_FILE']                  = '';
$DB['VERIFY_HOST']              = false;
$DB['CIPHER_LIST']              = '';

// Use IEEE754 compatible value range for 64-bit Numeric (float) history values.
// This option is enabled by default for new Zabbix installations.
// For upgraded installations, please read database upgrade notes before enabling this option.
$DB['DOUBLE_IEEE754']   = true;

$ZBX_SERVER                     = 'localhost';
$ZBX_SERVER_PORT                = '10051';
$ZBX_SERVER_NAME                = 'Zabbix Server';

$IMAGE_FORMAT_DEFAULT           = IMAGE_FORMAT_PNG;

// Uncomment this block only if you are using Elasticsearch.
// Elasticsearch url (can be string if same url is used for all types).
//$HISTORY['url'] = [
//      'uint' => 'http://localhost:9200',
//      'text' => 'http://localhost:9200'
//];
// Value types stored in Elasticsearch.
//$HISTORY['types'] = ['uint', 'text'];

// Used for SAML authentication.
// Uncomment to override the default paths to SP private key, SP and IdP X.509 certificates, and to set extra settings.
//$SSO['SP_KEY']                = 'conf/certs/sp.key';
//$SSO['SP_CERT']               = 'conf/certs/sp.crt';
//$SSO['IDP_CERT']              = 'conf/certs/idp.crt';
//$SSO['SETTINGS']              = [];
EOF

# Copy file to required directory
sudo cp ~/zabbix.conf.php /etc/zabbix/web/zabbix.conf.php

# Change permissions and owner for zabbix.conf.php file
sudo chown apache:apache /etc/zabbix/web/zabbix.conf.php
sudo chmod 0644 /etc/zabbix/web/zabbix.conf.php