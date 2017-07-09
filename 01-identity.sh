#!/bin/bash
#title           :01-identity.sh
#description     :This script has to be run after 00-prerequisites.sh on the Controller node. 
#author          :Rohan Dsouza
#usage           :bash 01-identity.sh  OR ./01-identity.sh 
#=========================================================================================================

echo -e "Installing and configuring the Identity service\n"
echo "Creating a user and a database named keystone. What would you like this user's password to be ?"
read -s keystone_mysql_passwd

mysql --user=root << EOF
 
CREATE DATABASE keystone;
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY '${keystone_mysql_passwd}';
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY '${keystone_mysql_passwd}';
FLUSH PRIVILEGES;

EOF

echo -e "Installing the Openstack Keystone service. Installation time may depend on your internet speed\n"
/usr/bin/yum install -y openstack-keystone httpd mod_wsgi >> /dev/null

echo -e "Making configuration changes now \n"

sed -i '/^#connection\ =\ <None>/a\connection\ =\ mysql+pymysql://keystone:@controller/keystone' /etc/keystone/keystone.conf
sed -i '/^#provider\ =\ uuid/a\provider = fernet' /etc/keystone/keystone.conf

echo -e "Syncing Keystone DB with the configuration changes made"

/usr/bin/su -s /bin/sh -c "/usr/bin/keystone-manage db_sync" keystone 2>> /dev/null

echo -e "Initializing Fernet key repositories\n"

/usr/bin/keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
/usr/bin/keystone-manage credential_setup --keystone-user keystone --keystone-group keystone

echo -e "Bootstraping the Identity service:\n"
echo "Kindly provide with a suitable password for the Admin user"
read -s keystone_passwd

echo "Accepted password. Finishing bootstraping of the Identity service..."
/usr/bin/keystone-manage bootstrap --bootstrap-password $keystone_passwd --bootstrap-admin-url http://controller:35357/v3/ --bootstrap-internal-url http://controller:35357/v3/ --bootstrap-public-url http://controller:5000/v3/ --bootstrap-region-id RegionOne 2>> /dev/null

sed -i '/^#ServerName/a\ServerName\ controller' /etc/httpd/conf/httpd.conf
/usr/bin/ln -s /usr/share/keystone/wsgi-keystone.conf /etc/httpd/conf.d/

cat << EOF > /root/admin-openrc

export OS_PROJECT_DOMAIN_NAME=Default
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=$keystone_passwd
export OS_AUTH_URL=http://controller:35357/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2

EOF

/usr/bin/systemctl enable httpd.service 2>> /dev/null
/usr/bin/systemctl restart httpd.service

echo -e "Installation of Keystone is complete. You may add users, groups and roles according to your requirements. \n"

echo "You may also read the further instructions in the README.md file"

exit 0
