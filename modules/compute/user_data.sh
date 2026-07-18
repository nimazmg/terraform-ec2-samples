#!/bin/bash
set -e

yum update -y
yum install -y httpd nfs-utils
systemctl start httpd
systemctl enable httpd

mkdir -p /var/www/html/shared
mount -t nfs4 -o nfsvers=4.1,rw ${efs_dns_name}:/ /var/www/html/shared

echo "${efs_dns_name}:/ /var/www/html/shared nfs4 defaults,_netdev 0 0" >> /etc/fstab
