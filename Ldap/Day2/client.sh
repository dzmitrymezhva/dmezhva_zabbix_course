#! /bin/bash

## install openldap-clients on client 
sudo yum -y install openldap-clients nss-pam-ldapd

## setting openldap-clients
sudo authconfig --enableldap --enableldapauth --ldapserver=10.3.1.100 --ldapbasedn="dc=dzmitry,dc=mezhva" --enablemkhomedir --update

## setting script 
# creat script for finding public key in openldap server
sudo cat > /opt/ssh_ldap.sh << SCRIPT
#!/bin/bash
set -eou pipefail
IFS=$'\n\t'
result=\$(ldapsearch -x '(&(objectClass=posixAccount)(uid='"\$1"'))' 'sshPublicKey')
attrLine=\$(echo "\$result" | sed -n '/^ /{H;d};/sshPublicKey:/x;\$g;s/\n *//g;/sshPublicKey:/p')
if [[ "\$attrLine" == sshPublicKey::* ]]; then
  echo "\$attrLine" | sed 's/sshPublicKey:: //' | base64 -d
elif [[ "\$attrLine" == sshPublicKey:* ]]; then
  echo "\$attrLine" | sed 's/sshPublicKey: //'
else
  exit 1
fi
SCRIPT

# change permissions for executing of script
sudo chmod 0750 /opt/ssh_ldap.sh

## setting shh service
# change ssh config file
sudo sed -i '/^PasswordAuthentication/s/no/yes/' /etc/ssh/sshd_config
sudo sed -i "s|#AuthorizedKeysCommand none|AuthorizedKeysCommand /opt/ssh_ldap.sh|" /etc/ssh/sshd_config
sudo sed -i "s|#AuthorizedKeysCommandUser nobody|AuthorizedKeysCommandUser root|" /etc/ssh/sshd_config

# restart sshd service
sudo systemctl restart sshd