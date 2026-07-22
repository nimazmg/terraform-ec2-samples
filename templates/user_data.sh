#!/bin/bash
set -euxo pipefail

if command -v apt-get >/dev/null 2>&1; then
  export DEBIAN_FRONTEND=noninteractive
  apt-get update -y
  apt-get install -y apache2 nfs-common
  sed -i "s/^Listen 80$/Listen ${application_port}/" /etc/apache2/ports.conf
  sed -i "s/<VirtualHost \*:80>/<VirtualHost *:${application_port}>/" /etc/apache2/sites-available/000-default.conf
  web_service=apache2
elif command -v dnf >/dev/null 2>&1; then
  dnf install -y httpd nfs-utils
  sed -i "s/^Listen 80$/Listen ${application_port}/" /etc/httpd/conf/httpd.conf
  web_service=httpd
elif command -v yum >/dev/null 2>&1; then
  yum install -y httpd nfs-utils
  sed -i "s/^Listen 80$/Listen ${application_port}/" /etc/httpd/conf/httpd.conf
  web_service=httpd
else
  echo "No supported package manager found" >&2
  exit 1
fi

systemctl enable --now "$web_service"

mount_point=/mnt/efs
efs_mount="${efs_dns_name}:/"
mkdir -p "$mount_point"

mounted=false
for attempt in $(seq 1 30); do
  if mount -t nfs4 -o nfsvers=4.1,rw "$efs_mount" "$mount_point"; then
    mounted=true
    break
  fi

  sleep 10
done

if [ "$mounted" != "true" ]; then
  echo "Unable to mount EFS after 30 attempts" >&2
  exit 1
fi

fstab_entry="$efs_mount $mount_point nfs4 defaults,_netdev,nofail 0 0"
grep -Fqx "$fstab_entry" /etc/fstab || echo "$fstab_entry" >> /etc/fstab

cat > /var/www/html/index.html <<EOF
<h1>${project_name}</h1>
<p>EFS is mounted at $mount_point.</p>
EOF

health_check_path="${health_check_path}"
if [ "$health_check_path" != "/" ]; then
  health_check_file="/var/www/html$health_check_path"
  case "$health_check_path" in
    */)
      mkdir -p "$health_check_file"
      echo "ok" > "$health_check_file/index.html"
      ;;
    *)
      mkdir -p "$(dirname "$health_check_file")"
      echo "ok" > "$health_check_file"
      ;;
  esac
fi
