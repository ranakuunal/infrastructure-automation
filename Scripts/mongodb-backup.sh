#!/bin/bash

set -euo pipefail

source /etc/wiz/mongodb-backup.env

TIMESTAMP=$(date -u +"%Y-%m-%dT%H-%M-%SZ")
BACKUP_FILE="/tmp/go-mongodb-${TIMESTAMP}.archive.gz"
S3_KEY="backups/go-mongodb-${TIMESTAMP}.archive.gz"

cleanup () {
    rm -f "$BACKUP_FILE"
}

trap cleanup EXIT

echo "Starting MongoDB backup at ${TIMESTAMP}"

mongodump \
  --host 127.0.0.1 \
  --port 27017 \
  --username "$MONGO_BACKUP_USER" \
  --password "$MONGO_BACKUP_PASSWORD" \
  --authenticationDatabase "$MONGO_AUTH_DB" \
  --db "$MONGO_DB" \
  --archive="$BACKUP_FILE" \
  --gzip

aws s3 cp \
  "$BACKUP_FILE" \
  "s3://${S3_BUCKET}/${S3_KEY}"

  echo "MongoDB backup complete"