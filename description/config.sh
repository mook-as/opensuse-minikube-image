#!/bin/bash

set -o nounset

#======================================
# Load functions.
#--------------------------------------
test -f /.kconfig && source /.kconfig
test -f /.profile && source /.profile

#======================================
# Greet.
#--------------------------------------
echo "Configure image: [$kiwi_iname]..."

#======================================
# Mount system filesystems.
#--------------------------------------
baseMount

#======================================
# Setup baseproduct link.
#--------------------------------------
suseSetupProduct

#======================================
# Add missing gpg keys to rpm.
#--------------------------------------
suseImportBuildKey
rpm --import /root/virtualization-containers.key
rm /root/virtualization-containers.key

#======================================
# Activate services.
#--------------------------------------
baseInsertService sshd
baseInsertService chronyd

ln -sf /lib/systemd/system/docker.service /usr/lib/systemd/system/docker.service
baseInsertService minikube-automount

#======================================
# Setup default target, multi-user.
#--------------------------------------
baseSetRunlevel 3

#==========================================
# Remove package docs.
#------------------------------------------
rm -rf /usr/share/doc/packages/*
rm -rf /usr/share/doc/manual/*
rm -rf /opt/kde*

#======================================
# SuSEconfig.
#--------------------------------------
suseConfig

#======================================
# Disable UseDNS.
#--------------------------------------
printf "%b" "
UseDNS no
GSSAPIAuthentication no
" >> /etc/ssh/sshd_config

#======================================
# Fix zypper defaults.
#--------------------------------------
printf "%b" "
solver.allowVendorChange = true
solver.onlyRequires = true
" >> /etc/zypp/zypp.conf

#======================================
# Write sudoers file.
#--------------------------------------
printf "%b" "
docker ALL=(ALL) NOPASSWD: ALL
" >> /etc/sudoers.d/docker

#======================================
# Disable multi kernel.
#--------------------------------------
sed -i 's/^multiversion/# multiversion/' /etc/zypp/zypp.conf

#======================================
# Remove non-static files.
#--------------------------------------
rm -rf /var/log/YaST2/config_diff_*.log
rm -rf /etc/zypp/repos.d/dir-*.repo

#======================================
# Prevent rebuilds.
#--------------------------------------
touch /var/lib/zypp/AutoInstalled
touch /var/lib/zypp/LastDistributionFlavor

#======================================
# Disable cronjobs.
#--------------------------------------
rm -rf /etc/cron.daily/*

#======================================
# Remove YaST if not in use.
#--------------------------------------
suseRemoveYaST

#======================================
# Umount kernel filesystems.
#--------------------------------------
baseCleanMount

#======================================
# Minikube symlinks.
#--------------------------------------

ln -sf /mnt/sda1/var/lib/rkt-etc /etc/rkt

ln -sf /mnt/sda1/var/log /tmp/log

ln -sf /mnt/sda1/var/lib/boot2docker /var/lib/boot2docker
ln -sf /mnt/sda1/var/lib/cni /var/lib/cni
ln -sf /mnt/sda1/var/lib/docker /var/lib/docker
ln -sf /mnt/sda1/var/lib/kubelet /var/lib/kubelet
ln -sf /mnt/sda1/var/lib/localkube /var/lib/localkube

#======================================
# Boot symlinks.
#--------------------------------------

ln -sf $(readlink /boot/vmlinuz) /boot/bzimage

#--------------------------------------

exit 0
