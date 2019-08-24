#!/bin/bash
#  Uses LVM to take snapshots of the /data volume and upload them to S3.
set -e

# Constants.
L_INFO="INFO"
L_ERROR="ERROR"
L_WARN="WARNING"

LVM_SNAP_MOUNT="/opt/backups/mnt"
LVM_SNAP_NAME="databackup"
LVM_SNAP_PATH="/dev/fedora/${LVM_SNAP_NAME}"
LVM_SRC_VOL="/dev/fedora/data"

START=$(date '+%Y%m%dT%H%M%S')
BACKUP_EXCLUDE_FILE="/opt/backups/excludes"
BACKUP_FULL="no"
BACKUP_INCREMENTAL_SNAPSHOT="/opt/backups/incremental.snapshot"
BACKUP_NAME_FULL="backup-${START}-full.tar.gz.enc"
BACKUP_NAME_INCR="backup-${START}-incr.tar.gz.enc"
GOF3R="/opt/backups/bin/gof3r"
SECRETS="/opt/backups/secrets"
S3_BUCKET="spogliani-backups"
S3_KEY_FULL="/automated/thinkpad-m910q/${BACKUP_NAME_FULL}"
S3_KEY_INCR="/automated/thinkpad-m910q/${BACKUP_NAME_INCR}"


# Helpers.
fail() {
  log ${L_ERROR} "$@"
  exit 1
}
info() {
  log ${L_INFO} "$@"
}
warn() {
  log ${L_WARN} "$@"
}

log() {
  level=$1
  shift
  echo "$(date '+%F %T') [${level}]" "$@"
}

cleanup() {
  if $(mount | grep "${LVM_SNAP_MOUNT}" > /dev/null); then
    info "Unmounting snapshot ..."
    umount "${LVM_SNAP_MOUNT}"
  else
    warn "Snapshot seems not to be mounted!"
  fi
  lvremove --force "${LVM_SNAP_PATH}" || fail "Unable to remove LVM snapshot!"
}

clean_fail() {
  cleanup
  fail "$@"
}

check_lvm_name() {
  lvdisplay "${LVM_SNAP_PATH}" > /dev/null 2> /dev/null
}


### Main ###
# Check if a full backup was requested.
if [ "$1" == "--full" ]; then
  BACKUP_FULL="yes"
fi

# Load secrets if present.
[ -f "${SECRETS}" ] && . "${SECRETS}"

# Log IP daily in case DDNS fails.
MY_IP=$(dig +short myip.opendns.com @resolver1.opendns.com)
info "Detected public IP: ${MY_IP}"


### Validate Environment ###
info "*** Validating environment ***"
info "LVM Origin: ${LVM_SRC_VOL}"
[ -b "${LVM_SRC_VOL}" ] || fail "Unable to find volume to snapshot"

info "LVM Snapshot name: ${LVM_SNAP_NAME}"
check_lvm_name && fail "Found a volume with the snapshot name"

info "Read only mountpoint: ${LVM_SNAP_MOUNT}"
[ -d "${LVM_SNAP_MOUNT}" ] || fail "Mountpoint is not a directory"
[ -z "$(ls -A "${LVM_SNAP_MOUNT}")" ] || fail "Mountpoint is not empty"
echo -e '\n'


### Create and mount snapshot ###
info "*** Creating snaphot ***"
lvcreate --snapshot "${LVM_SRC_VOL}" \
  --size 90G --name "${LVM_SNAP_NAME}" \
  || fail "Unable to create snapshot volume"

info "*** Mounting read only ***"
mount --options nouuid --read-only \
  "${LVM_SNAP_PATH}" "${LVM_SNAP_MOUNT}" \
  || clean_fail "Unable to mount snapshot origin"
echo -e '\n'


### Do the backup ###
backup_s3_key=${S3_KEY_INCR}
if [ "${BACKUP_FULL}" == "yes" ]; then
  info "Requested full backup"
  backup_s3_key=${S3_KEY_FULL}
  rm -f "${BACKUP_INCREMENTAL_SNAPSHOT}"
fi

info "*** Starting backup from snaphot ***"
backup_exclude=""
if [ -f "${BACKUP_EXCLUDE_FILE}" ]; then
  backup_exclude="--exclude-from=${BACKUP_EXCLUDE_FILE}"
fi
tar "--directory=${LVM_SNAP_MOUNT}" \
  --no-check-device "--listed-incremental=${BACKUP_INCREMENTAL_SNAPSHOT}" \
  ${backup_exclude} --recursive --atime-preserve=system \
  --create --acls --xattrs --gzip . \
  | openssl enc -aes-256-cbc -pbkdf2 -e -pass file:/opt/backups/backups.key \
  | ${GOF3R} put --endpoint "s3-eu-central-1.amazonaws.com" \
    --bucket "${S3_BUCKET}" --key "${backup_s3_key}"


### Clean up mount and volume ###
info "Cleaning up after backup completed"
cleanup
