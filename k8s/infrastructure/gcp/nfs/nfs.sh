#!/bin/bash

apt-get update
apt-get -y install nfs-kernel-server nfs-common
mkdir /fileshare_name
chown -R nobody:nogroup /fileshare_name
chmod 750 /fileshare_name
echo "/fileshare_name network(rw,sync,no_root_squash,no_subtree_check)" >> /etc/exports
exportfs -a
service nfs-kernel-server restart