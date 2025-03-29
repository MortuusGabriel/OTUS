#!/bin/sh
apk add nfs-utils
mkdir -p /mnt

echo "192.168.50.10:/srv/share /mnt nfs vers=3,noauto,x-systemd.automount 0 0" >> /etc/fstab
mount -a
