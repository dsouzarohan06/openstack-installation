#!/bin/bash
#title           :02-image.sh
#description     :This script has to be run after 01-identity.sh on the Controller node.
#author          :Rohan Dsouza
#usage           :bash 02-image.sh  OR ./02-image.sh
#=========================================================================================================

cat << EOF

This is not complete yet. Please do not use this script.

EOF

echo -e "Installing and configuring the Image service\n"

source /root/admin-openrc

echo -e "Creating A PROJECT named 'service'\n"

openstack project create --domain default --description "Service Project" service

echo -e "Creating A PROJECT named 'demo'\n"

openstack project create --domain default --description "Demo Project" demo

echo -e "Creating the demo user. Kindly provide the password that you would like to set for this user."

openstack user create --domain default --password-prompt demo

echo "Creating a Role named 'user'\n"

openstack role create user

echo "Now, we are adding the user role to the demo project and user"

openstack role add --project demo --user demo user

echo "Creating a database and a user named glance. What would you like the glance user's password to be?"
read -s glance_mysql_passwd

mysql --user=root << EOF

CREATE DATABASE glance;
GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY '${glance_mysql_passwd}';
GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY '${glance_mysql_passwd}';
FLUSH PRIVILEGES;

EOF

echo -e "Creating a user named 'glance' in openstack. Kindly enter an appropriate password for this user\n"
openstack user create --domain default --password-prompt glance

echo -e "Adding the admin role to the glance user and service project"
openstack role add --project service --user glance admin

echo -e "Creating the glance service entity"

openstack service create --name glance --description "OpenStack Image" image

echo -e "Creating the 3 endpoints i.e public, internal and admin"

openstack endpoint create --region RegionOne image public http://controller:9292

openstack endpoint create --region RegionOne image internal http://controller:9292

openstack endpoint create --region RegionOne image admin http://controller:9292

echo -e "Finally installing the glance package\n"

yum install openstack-glance >> /dev/null


