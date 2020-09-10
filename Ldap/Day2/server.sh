#! /bin/bash

#### ----------==========DAY1==========----------
### setting openldap server
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
pass_user=8866697
pass_admin=74501133
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
ldapadd -x -D cn=Manager,dc=dzmitry,dc=mezhva -w "$pass_admin" << EOF
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

### setting UI for openldap server
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

#### ----------==========DAY2==========----------
### setting openldap server
## update configuration openldap server
# add ssh schema
sudo ldapadd -Y EXTERNAL -H ldapi:/// << EOF
dn: cn=openssh-lpk,cn=schema,cn=config
objectClass: olcSchemaConfig
cn: openssh-lpk
olcAttributeTypes: ( 1.3.6.1.4.1.24552.500.1.1.1.13 NAME 'sshPublicKey'
    DESC 'MANDATORY: OpenSSH Public key'
    EQUALITY octetStringMatch
    SYNTAX 1.3.6.1.4.1.1466.115.121.1.40 )
olcObjectClasses: ( 1.3.6.1.4.1.24552.500.1.1.2.0 NAME 'ldapPublicKey' SUP top AUXILIARY
    DESC 'MANDATORY: OpenSSH LPK objectclass'
    MAY ( sshPublicKey $ uid )
    )
EOF

# update configuration openldap server
sudo ldapmodify -x -D cn=Manager,dc=dzmitry,dc=mezhva -w "$pass_admin" -H ldap:/// << EOF
dn: uid=dmezhva,ou=People,dc=dzmitry,dc=mezhva
changeType: modify
add: objectClass
objectClass: ldapPublicKey
-
add: sshPublicKey
sshPublicKey: ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCrsn/WNnGjKTJviTOEUTuMmql4qph+jPEh/AGeVN9LCvI05HJ57k5yvqRiMifynWy78gzeEL0mEtYmv5z2bL6bvhpwwQHit30JBLLQqY/AYj4IUR06EWmKUO+GDKha5G+a0DTz7JlHkd+DBYOAryVOoNeUdoqrki3KSrV7Ur30MNpfcx8+xJk9EbubLFfg2YC8vrYg2LjRbXw3KvPRZD5tnecA+QIrAgDlsqSIYKmuDYuGKObxpwzAKMtt2cu24OKYpx68gBxUnKC6Et6pKUrPFIrslJNa0SY0DsilFaowdgS5oejBrbV7niBZZ4F1uAtLzMRjjz2tcusen+4Cw1vDfmEfpOthGzbJjzAyF9GqJxMptqqgXefOepu4o6NeZS0pjmc/e89hqlqkhuqPDyJhK6iydFLys/ABM+yXsFf1nR8RIHCjIjdsqnH7kcqX66SNhisOZ/zp6b/3pMxeo0+JPdVGGEyAYxHZpsHXgxLELHNVt5bN4Gq4onhszAigftc= Dzmitry Mezhva@NAME-BQNMOAMNSO
EOF