# openstack-installation
Installation of Openstack on CentOS 7

Before starting with installation, make sure you have the following:

1. You require 2 nodes, 1 node will be the controller node on which services like Identity, Networking, Image storage etc. will be installed while the Compute service will be installed on the 2nd node for simplicity.

2. Install CentOS 7 Minimal version on both these nodes. Provide both these nodes with a Static IP and not via DHCP so that their IP does not change under any circcumstances. Furthermore, both these nodes should have access to the internet.

3. Set the hostname of the first node as 'controller' while the hostname of the 2nd node as 'compute' for simplicity. Both these boxes should be reachable via hostnames. Hence, add the IP address and the hostnames ( controller and compute ) such that they can ping themselves as well as the other node. For this, adding an entry in /etc/hosts is just fine.

4. Stop firewalld and NetworkManager services on both these nodes. Also, disable both these services so that they do not start again post reboot.

5. Disable selinux. Also, just do a 'yum update -y' on both these nodes so as to make sure that both these nodes have the latest kernels and the latest applications installed.


i) To start off with the installation, run the first script i.e 00-prerequisites.sh

Usage:  ./00-prerequisites.sh   <controller|compute>

If you are running it on the controller node, use 'controller' as the argument. Else, if you are running it on the compute node, use 'compute' as the argument.

For eg.:

[root@controller openstack-installation]# ./00-prerequisites.sh controller
Installing and configuring NTP service now
Enter the NTP server of your choice


ii) Post running the 00-prerequisites.sh script, it's now time to install the Identity service of OpenStack a.k.a Keystone. It's now time to run an another script which will install and configure Keystone for us. The script name is: 01-identity.sh

Usage:  ./01-identity.sh

PS: The above mentioned script needs to be run on the controller node. I'll specifically mention which script has to be run on the compute node.

Post running the 01-identity.sh, to verify if everything has installed correctly, run the following commands:


[root@controller ~]# source /root/admin-openrc
[root@controller ~]# openstack user list
+----------------------------------+-------+
| ID                               | Name  |
+----------------------------------+-------+
| 39056e2af63b407a97d5ec69ddf93241 | admin |
+----------------------------------+-------+

If you do not get the desired output, check for Errors in /var/log/keystone/keystone.log






PS: This is not complete. Will complete it ASAP
