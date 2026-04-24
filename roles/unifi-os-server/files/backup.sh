#!/bin/bash

set -e

echo "Running backup script for $SERVICE_NAME"

TIMESTAMP=$(date +%Y%m%d-%H%M%S)
TIMESTAMP_RFC3339=$(date --rfc-3339=seconds)

# UniFi OS Server writes .unf backups under $BACKUP_FROM. Pick the newest.
LATEST_UNF=$(find "${BACKUP_FROM}" -maxdepth 2 -type f -name '*.unf' -printf '%T@ %p\n' 2>/dev/null | sort -rn | head -1 | cut -d' ' -f2-)

if [ -z "${LATEST_UNF}" ]; then
  echo "No .unf backup found under ${BACKUP_FROM}" >&2
  exit 1
fi

FILENAME="${SERVICE_NAME}-backup-${TIMESTAMP}.unf"
STAGE_FILE="/tmp/${FILENAME}"

trap 'echo "Backup failed. Cleaning up..."; rm -f "${STAGE_FILE}"; exit 1' ERR

echo "Staging ${LATEST_UNF} -> ${STAGE_FILE}"
cp "${LATEST_UNF}" "${STAGE_FILE}"

trap - ERR

echo "Uploading to s3://${BUCKET_NAME}/${S3_PREFIX}/${SERVICE_NAME}-latest.unf"
aws s3 cp "${STAGE_FILE}" "s3://${BUCKET_NAME}/${S3_PREFIX}/${SERVICE_NAME}-latest.unf"

echo "Publishing time to topic ${MOSQUITTO_TOPIC}"
mosquitto_pub -h "${MOSQUITTO_HOST}" -t "${MOSQUITTO_TOPIC}" -m "${TIMESTAMP_RFC3339}" -u "${MOSQUITTO_USERNAME}" -P "${MOSQUITTO_PASSWORD}" --retain

rm -f "${STAGE_FILE}"

echo "Backup complete: ${FILENAME}"
