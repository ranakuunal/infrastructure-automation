#!/bin/bash

set -e

exec > >(tee /var/log/mongodb-bootstrap.log | logger -t user-data -s 2>/dev/console) 2>&1

echo "Starting MongoDB setup ...."

# Creating MongoDB 6.0 repository
cat > /etc/yum.repos.d/mongodb-org-6.0.repo <<'EOF'
[mongodb-org-6.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/amazon/2/mongodb-org/6.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-6.0.asc
EOF

# Installing MongoDB 6.0
yum clean all
yum makecache
yum install -y mongodb-org xfsprogs

# Ensures MongoDB cannot write to root volume before the data EBS is mounted
systemctl stop mongod 2>/dev/null || true

echo "Waiting for MongoDB data EBS volume..."

# Find the root disk
ROOT_SOURCE=$(findmnt -n -o SOURCE /)
ROOT_DISK_NAME=$(lsblk -no PKNAME "$ROOT_SOURCE" | head -n 1)

if [ -n "$ROOT_DISK_NAME" ]; then
  ROOT_DISK="/dev/${ROOT_DISK_NAME}"
else
  ROOT_DISK="$ROOT_SOURCE"
fi

# Buffer of 5 minutes for separate EBS volume to appear
for i in $(seq 1 60); do
  DATA_DEVICE=$(lsblk -dpno NAME,TYPE | \
    awk '$2 == "disk" {print $1}' | \
    grep -v "^${ROOT_DISK}$" | \
    head -n 1 || true)
  
  if [ -n "$DATA_DEVICE" ]; then
    break
  fi

  echo "Waiting for data volume..."
  sleep 5
done

if [ -z "${DATA_DEVICE:-}" ]; then
  echo "MongoDB data volume was not detected."
  exit 1
fi

echo "MongoDB data volume detected: ${DATA_DEVICE}"

# Formats only if the volume is new. Existing volume may contain MongoDB data from the previous instance
if ! blkid "$DATA_DEVICE" >/dev/null 2>&1; then
  echo "New data volume detected. Creating XFS filesystem."
  mkfs.xfs -f "$DATA_DEVICE"
else
  echo "Existing data volume detected."
fi

# MongoDB's default location
mkdir -p /var/lib/mongo

DATA_UUID=$(blkid -s UUID -o value "$DATA_DEVICE")

if ! grep -q "UUID=${DATA_UUID}" /etc/fstab; then
  echo "UUID=${DATA_UUID} /var/lib/mongo xfs defaults 0 2" >> /etc/fstab
fi

# Mount the MongoDB data volume
if ! mountpoint -q /var/lib/mongo; then
  mount /var/lib/mongo
fi

# Verify the MongoDB data volume
mountpoint -q /var/lib/mongo

# Giving ownership of the data directory
chown -R mongod:mongod /var/lib/mongo

# Ensures MongoDB never starts without MongoDB data volume
mkdir -p /etc/systemd/system/mongod.service.d

cat > /etc/systemd/system/mongod.service.d/override.conf <<'EOF'
[Unit]
RequiresMountsFor=/var/lib/mongo
EOF

systemctl daemon-reload

PRIVATE_IP=$(hostname -I | awk '{print $1}')

# Allows MongoDB to listen on localhost and EC2 Private IP
sed -i -E \
  "s/^([[:space:]]*)bindIp:[[:space:]]*.*/\1bindIp: 127.0.0.1,${PRIVATE_IP}/" \
  /etc/mongod.conf
grep -F "bindIp: 127.0.0.1,${PRIVATE_IP}" /etc/mongod.conf

# Enable MongoDB authentication
if ! grep -q "^security:" /etc/mongod.conf; then
  cat >> /etc/mongod.conf <<'EOF'

security:
  authorization: enabled
EOF
fi

# Enable and start MongoDB
systemctl enable mongod
systemctl restart mongod

# Verify MongoDB service started
systemctl is-active --quiet mongod
systemctl is-enabled --quiet mongod

echo "MongoDB setup complete."
mongod --version