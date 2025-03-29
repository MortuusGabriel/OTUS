#!/bin/sh
apk add nfs-utils
mkdir -p /srv/share/upload
chmod 0777 /srv/share/upload
chown -R nobody:nogroup /srv/share

cat << EOT > /etc/exports
/srv/share 192.168.50.11/32(rw,sync,no_root_squash)
EOT

rc-service nfs start
rc-update add nfs default
exportfs -r
