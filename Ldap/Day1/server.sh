#! /bin/bash

### configuration openldap server
## install openldap
sudo yum install -y openldap openldap-servers openldap-clients

## create firewall rule for openldap
sudo firewall-cmd --add-service=ldap

## copy empty openldap database
sudo cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG

## change owner for openldap database
sudo chown -R ldap:ldap /var/lib/ldap/DB_CONFIG

## start openldap
sudo systemctl start slapd

## add openldap to startup
sudo systemctl enable slapd

## add schemes to openldap
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/cosine.ldif 
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/nis.ldif
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/inetorgperson.ldif

## create encrypted password
pass_user=123
pass_admin=321
pass_ssha=$(slappasswd -h {SSHA} -s $pass_admin)

## update configuration openldap server
#1
sudo ldapadd -Y EXTERNAL -H ldapi:/// << EOF
dn: olcDatabase={0}config,cn=config
changetype: modify
add: olcRootPW
olcRootPW: $pass_ssha
EOF

#2
sudo ldapmodify -Y EXTERNAL -H ldapi:/// << EOF
dn: olcDatabase={1}monitor,cn=config
changetype: modify
replace: olcAccess
olcAccess: {0}to * by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" read by dn.base="cn=Manager,dc=dzmitry,dc=mezhva" read by * none

dn: olcDatabase={2}hdb,cn=config
changetype: modify
replace: olcSuffix
olcSuffix: dc=dzmitry,dc=mezhva

dn: olcDatabase={2}hdb,cn=config
changetype: modify
replace: olcRootDN
olcRootDN: cn=Manager,dc=dzmitry,dc=mezhva

dn: olcDatabase={2}hdb,cn=config
changetype: modify
add: olcRootPW
olcRootPW: $pass_ssha

dn: olcDatabase={2}hdb,cn=config
changetype: modify
add: olcAccess
olcAccess: {0}to attrs=userPassword,shadowLastChange by dn="cn=Manager,dc=dzmitry,dc=mezhva" write by anonymous auth by self write by * none
olcAccess: {1}to dn.base="" by * read
olcAccess: {2}to * by dn="cn=Manager,dc=dzmitry,dc=mezhva" write by * read
EOF

#3
sudo ldapadd -x -D cn=Manager,dc=dzmitry,dc=mezhva -w "$pass_admin" << EOF
dn: dc=dzmitry,dc=mezhva
objectClass: top
objectClass: dcObject
objectclass: organization
o: dzmitry mezhva
dc: dzmitry

dn: cn=Manager,dc=dzmitry,dc=mezhva
objectClass: organizationalRole
cn: Manager
description: Directory Manager

dn: ou=People,dc=dzmitry,dc=mezhva
objectClass: organizationalUnit
ou: People

dn: ou=Group,dc=dzmitry,dc=mezhva
objectClass: organizationalUnit
ou: Group
EOF

#4
sudo ldapadd -x -D "cn=Manager,dc=dzmitry,dc=mezhva" -w "$pass_admin" << EOF
dn: cn=Manager,ou=Group,dc=dzmitry,dc=mezhva
objectClass: top
objectClass: posixGroup
gidNumber: 1005
EOF

#5
ldapadd -x -D cn=Manager,dc=dzmitry,dc=mezhva -w "$pass_admin"<< EOF
dn: uid=dmezhva,ou=People,dc=dzmitry,dc=mezhva
objectClass: top
objectClass: account
objectClass: posixAccount
objectClass: shadowAccount
cn: dmezhva
uid: dmezhva
uidNumber: 1005
gidNumber: 1005
homeDirectory: /home/dmezhva
userPassword: $pass_user
loginShell: /bin/bash
gecos: dmezhva
shadowLastChange: 0
shadowMax: -1
shadowWarning: 0
EOF

### configuration UI for openldap server
## install php ldap admin
sudo yum --enablerepo=epel install -y phpldapadmin

## uncomment 397 line
sudo sed -i '397s|// ||' /etc/phpldapadmin/config.php

## comment out 398 line
sudo sed -i '398s|^|// |' /etc/phpldapadmin/config.php

## edit apache config file
sudo cat > /etc/httpd/conf.d/phpldapadmin.conf << EOF
Alias /phpldapadmin /usr/share/phpldapadmin/htdocs
Alias /ldapadmin /usr/share/phpldapadmin/htdocs
<Directory /usr/share/phpldapadmin/htdocs>
  <IfModule mod_authz_core.c>
    Require all granted
  </IfModule>
  <IfModule !mod_authz_core.c>
    Order Deny,Allow
    Deny from all
    Allow from all
    Allow from ::1
  </IfModule>
</Directory>
EOF

## restart apache server
sudo systemctl restart httpd