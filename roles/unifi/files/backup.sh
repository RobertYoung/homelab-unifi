#!/bin/bash

set -e

echo "Running backup script for $SERVICE_NAME"

TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_DIR="/tmp/backup-${TIMESTAMP}"
FILENAME="${SERVICE_NAME}-backup-${TIMESTAMP}.tar.gz"
TAR_FILE="/tmp/${FILENAME}"

mkdir -p "${BACKUP_DIR}"

trap 'echo "Backup failed. Cleaning up..."; rm -rf "${BACKUP_DIR}" "${TAR_FILE}"; exit 1' ERR

# Backup MongoDB
echo "Dumping MongoDB..."
mongodump --host mongodb --port 27017 --out "${BACKUP_DIR}/mongodb"
echo "MongoDB dump complete"

# Backup UniFi data
echo "Copying UniFi data..."
cp -r /backup/unifi "${BACKUP_DIR}/unifi"
echo "UniFi data copy complete"

# Create tarball
echo "Creating tarball ${TAR_FILE}..."
cd "${BACKUP_DIR}"
tar -czvf "${TAR_FILE}" --warning=none .
echo "Tarball created"

trap - ERR

# Upload to S3
echo "Uploading to s3://${BUCKET_NAME}/${SERVICE_NAME}/${SERVICE_NAME}-latest.tar.gz"
aws s3 cp "${TAR_FILE}" "s3://${BUCKET_NAME}/${SERVICE_NAME}/${SERVICE_NAME}-latest.tar.gz"

# Cleanup
rm -rf "${BACKUP_DIR}" "${TAR_FILE}"

echo "Backup complete: ${FILENAME}"
