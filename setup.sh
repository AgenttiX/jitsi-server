#!/usr/bin/env bash
set -eu

# Based on
# https://jitsi.github.io/handbook/docs/devops-guide/devops-guide-docker

if [ "${EUID}" -eq 0 ]; then
  echo "This script should not be run as root."
  exit 1
fi

if ! command -v unzip &> /dev/null; then
  echo "Unzip was not found. Installing."
  sudo apt-get update
  sudo apt-get install unzip
fi
if ! command -v rsync &> /dev/null; then
  echo "Rsync was not found. Installing."
  sudo apt-get install rsync
fi

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
URL="$(curl -s https://api.github.com/repos/jitsi/docker-jitsi-meet/releases/latest | grep 'zip' | cut -d\" -f4)"
URL_FILENAME="${URL##*/}"
ZIP_PATH="${SCRIPT_DIR}/${URL_FILENAME}.zip"
TEMP_PATH="${SCRIPT_DIR}/${URL_FILENAME}"
JITSI_PATH="${SCRIPT_DIR}/jitsi"
CONFIG_PATH="${SCRIPT_DIR}/config"

wget "${URL}" -O "${ZIP_PATH}"
unzip "${ZIP_PATH}" -d "${TEMP_PATH}"
mkdir -p "${JITSI_PATH}"
rsync --archive --verbose --ignore-times "${TEMP_PATH}/jitsi-docker-jitsi-meet-"*/ "${JITSI_PATH}"
rm -r "${TEMP_PATH}"

if [ ! -f "${JITSI_PATH}/.env" ]; then
  cp "${JITSI_PATH}/env.example" "${JITSI_PATH}/.env"
  "${JITSI_PATH}/gen-passwords.sh"
fi

mkdir -p "${CONFIG_PATH}"/{web,transcripts,prosody/config,prosody/prosody-plugins-custom,jicofo,jvb,jigasi,jibri}
