#!/usr/bin/env bash
set -eu

if [ "${EUID}" -ne 0 ]; then
  echo "This script should be run as root."
  exit 1
fi

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
SERVERS_DIR="/etc/nginx/conf.d/servers"

echo "Installing jitsi server configs."

if [ ! -d "${SERVERS_DIR}" ]; then
  mkdir -p "${SERVERS_DIR}"
fi

if [ ! -L "${SERVERS_DIR}/media-servers.conf" ]; then
  ln -s "${SCRIPT_DIR}/conf/jitsi-servers.conf" "${SERVERS_DIR}/jitsi-servers.conf"
  # ln -s "${SCRIPT_DIR}/conf/jitsi-settings.conf" "${SERVERS_DIR}/jitsi-settings.conf"
fi

systemctl restart nginx.service
systemctl status nginx.service

echo "Configs installed."
