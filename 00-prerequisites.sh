#!/bin/bash       
#title           :00-prerequisites.sh
#description     :This is the first script to be run. This will install all the prerequisites needed before installation of openstack.
#author		 :Rohan Dsouza
#usage		 :bash mkscript.sh
#==============================================================================

if [ $# == 0 ]; then
echo "Usage:  $0   <controller|compute>"
exit 1
fi

if [ $1 == controller ]; then

#  _   _ _____ ____ 
# | \ | |_   _|  _ \
# |  \| | | | | |_) |
# | |\  | | | |  __/
# |_| \_| |_| |_| 


echo "Installing and configuring NTP service now"

/usr/bin/yum install -y chrony >>/dev/null
echo "Enter the NTP server of your choice"
read ntp_server
/usr/bin/sed -i '/^server/d' /etc/chrony.conf
echo "server $ntp_server iburst" >> /etc/chrony.conf
echo "allow " `/usr/sbin/ip route | awk '{print $1}' | tail -1` >> /etc/chrony.conf 

/usr/bin/systemctl enable chronyd.service 2>> /dev/null
/usr/bin/systemctl restart chronyd.service

echo "Congratulations !! NTP service has now been installed and configured !!"

# _________________________________________
#/ We're going to install Openstack Newton \
#\ now                                     /
# -----------------------------------------
#        \   ^__^
#         \  (oo)\_______
#            (__)\       )\/\
#                ||----w |
#                ||     ||


echo "Installing Openstack packages now."
/usr/bin/yum install -y centos-release-openstack-newton >> /dev/null

echo "Now we are upgrading all the packages. Installation time may depend on your internet speed"
/usr/bin/yum -y upgrade >> /dev/null

echo "All packages have now been upgraded. Now installing the Openstack client. Again, installation time may depend on your internet speed :)"

/usr/bin/yum install -y python-openstackclient openstack-selinux >> /dev/null

echo "Rejoice !! All packages have now been updated"


# ____________________________________
#< We're going to install MariaDB now >
# ------------------------------------
#        \   ^__^
#         \  (oo)\_______
#            (__)\       )\/\
#                ||----w |
#                ||     ||

echo "We are installing MariaDB now"
/usr/bin/yum install -y mariadb mariadb-server python2-PyMySQL >> /dev/null

cat << EOF > /etc/my.cnf.d/openstack.cnf

[mysqld]
bind-address = `/usr/sbin/ip route | tail -1 | awk '{print $NF}'`

default-storage-engine = innodb
innodb_file_per_table
max_connections = 4096
collation-server = utf8_general_ci
character-set-server = utf8

EOF

/usr/bin/systemctl enable mariadb.service 2>> /dev/null
/usr/bin/systemctl start mariadb.service

echo "We are done installing MariaDB. We are configuring it for you now. What would you like to keep the mysql's root user's password to be?"
read -s mysql_root_passwd

mysql --user=root << EOF
UPDATE mysql.user SET Password=PASSWORD('${mysql_root_passwd}') WHERE User='root';
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
EOF

echo "Congratulations, MariaDB is successfully installed and configured. Now its time to install and configure RabbitMQ which will act as a message queue"

/usr/bin/yum install -y rabbitmq-server >> /dev/null

/usr/bin/systemctl enable rabbitmq-server.service 2>> /dev/null
/usr/bin/systemctl restart rabbitmq-server.service 

echo "We are creating a user named openstack for RabbitMQ. What would you like the user's password to be?"
read -s rabbitmq_passwd

/usr/sbin/rabbitmqctl add_user openstack $rabbitmq_passwd 
/usr/sbin/rabbitmqctl set_permissions openstack ".*" ".*" ".*"

echo "RabbitMQ is all set. Installing the last service in this script which is Memcached"

# __  __                               _              _
#|  \/  | ___ _ __ ___   ___ __ _  ___| |__   ___  __| |
#| |\/| |/ _ \ '_ ` _ \ / __/ _` |/ __| '_ \ / _ \/ _` |
#| |  | |  __/ | | | | | (_| (_| | (__| | | |  __/ (_| |
#|_|  |_|\___|_| |_| |_|\___\__,_|\___|_| |_|\___|\__,_|

/usr/bin/yum install -y memcached python-memcached >> /dev/null

/usr/bin/sed -i '/^OPTIONS/d' /etc/sysconfig/memcached


/usr/bin/systemctl enable memcached.service 2>> /dev/null
/usr/bin/systemctl restart memcached.service

/usr/bin/sed -i '/^OPTIONS/d' /etc/sysconfig/memcached
echo "OPTIONS=`/usr/sbin/ip route | tail -1 | awk '{print $NF}'`" >> /etc/sysconfig/memcached

echo "Good news, all installation has been done and you can proceed to the next script"

exit 0

###############################################################################################


elif [ $1 == compute ]; then

#  _   _ _____ ____
# | \ | |_   _|  _ \
# |  \| | | | | |_) |
# | |\  | | | |  __/
# |_| \_| |_| |_|


echo "Installing and configuring NTP service now"

/usr/bin/yum install -y chrony >> /dev/null
/usr/bin/sed -i '/^server/d' /etc/chrony.conf
echo "server controller iburst" >> /etc/chrony.conf

/usr/bin/systemctl enable chronyd.service 2>> /dev/null
/usr/bin/systemctl restart chronyd.service

echo "Congratulations !! NTP service has now been installed and configured !!" 

# _________________________________________
#/ We're going to install Openstack Newton \
#\ now                                     /
# -----------------------------------------
#        \   ^__^
#         \  (oo)\_______
#            (__)\       )\/\
#                ||----w |
#                ||     ||
                            

echo "Installing Openstack packages now."
/usr/bin/yum install -y centos-release-openstack-newton >> /dev/null

echo "Now we are upgrading all the packages. Installation time may depend on your internet speed"
/usr/bin/yum -y upgrade >> /dev/null

echo "All packages have now been upgraded. Now installing the Openstack client. Again, installation time may depend on your internet speed :)"

/usr/bin/yum install -y python-openstackclient openstack-selinux >> /dev/null

echo "Rejoice !! All packages have now been updated"

echo "Prerequisites for your compute node are done. Please read the README.md file for next steps." 

exit 0

else

echo -e "Invalid argument. Either select controller or compute as an argument depending on the server you are on."
echo "Incase any issues, read the README.md for help"

fi




