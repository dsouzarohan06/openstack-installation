# openstack-installation
Installation of Openstack on CentOS 7

Before starting with installation, make you have the following:

1. You require 2 nodes, 1 node will be the controller on which services like Identity, Networking, Image storage etc. will be installed while the Compute service will be installed on the 2nd node for simplicity.

2. Install CentOS 7 Minimal version on both these nodes. Provide both these nodes with a Static IP and not DHCP so that their IP does not change under any circcumstances. Furthermore, both these nodes should have access to the internet.

3. Set the hostname of the first node as 'controller' while the hostname of the 2nd node as 'compute' for simplicity.

4. Stop firewalld and NetworkManager services on both these nodes. Also, disable both these services so that they do not start again post reboot.

5. Disable selinux. Also, just do a 'yum update -y' on both these nodes so as to make sure that both these nodes have the latest kernels and latest applications.

6. Both these boxes should be reachable via hostnames. Hence, add the IP address and the hostnames ( Controller and Compute ) such that they can ping themselves as well as the other node. For this, adding an entry in /etc/hosts is just fine.

To start off with the installation, run the first script i.e 00-prerequisites.sh

Usage:  ./00-prerequisites.sh   <controller|compute>

If you are running it on the controller node, use 'controller' as the argument. Else, if you are running it on the compute node, use 'compute' as the argument.

For eg.:

[root@controller openstack-installation]# ./00-prerequisites.sh controller
Installing and configuring NTP service now
Enter the NTP server of your choice





PS: This is not complete. Will complete it ASAP
