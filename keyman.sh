#!/bin/bash

set -euo pipefail

set -a
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
QUAY="${script_dir}"
QUAY_URL="192.168.1.197"
QUAY_HOSTPATH="${QUAY}/storage"
PSQL_HOSTPATH="${QUAY}/postgresql-quay"

usage() {
  cat <<EOF
Usage:
  $(basename "${BASH_SOURCE[0]}") [options]

Available options:

ps       podman ps -a
start    deploy quay
stop     delete quay
stop -v  delete quay and hostPath volume
clean    delete hostPath volume
EOF
  exit
}

wait_quay_ready() {
  echo -n "wait quay ready..."
  until [ "$(curl -s ${QUAY_URL} -o /dev/null --write-out '%{http_code}')" -eq 200 ]; do
    sleep 5
  done
  echo "ok"
}

super_user_data() {
  cat <<EOF
{
    "username": "quay",
    "password": "Quay12345",
    "email": "quay@cia.com"
}
EOF
}

create_super_user() {
  curl -X POST -k http://"${QUAY_URL}"/api/v1/user/initialize \
    --header 'Content-Type: application/json' \
    --data "$(super_user_data)" &>/dev/null

  echo "create superuser [quay] successfully!"
}

if ! command -v envsubst &>/dev/null; then
  echo "Command 'envsubst' not found" && exit 1
fi

case "${1-}" in
start)
  if sudo podman pod ps | grep "quay" &>/dev/null; then
    echo "quay is deployed!" && exit 1
  fi

  if [ ! -d "${PSQL_HOSTPATH}" ]; then
    mkdir -p "${PSQL_HOSTPATH}"
    setfacl -m u:26:-wx "${PSQL_HOSTPATH}"
  fi

  if [ ! -d "${QUAY_HOSTPATH}" ]; then
    mkdir -p "${QUAY_HOSTPATH}"
    setfacl -m u:1001:-wx "${QUAY_HOSTPATH}"
  fi

  envsubst <"${QUAY}"/config/config.yaml.temp >"${QUAY}"/config/config.yaml
  envsubst <quay-pod.yaml | sudo podman play kube -

  wait_quay_ready
  create_super_user
  ;;
stop)
  if sudo podman pod ps | grep "quay" &>/dev/null; then
    sudo podman pod stop quay
    sudo podman pod rm quay
  else
    echo "quay is not deployed!" && exit 1
  fi

  if [ "${2-}" == "-v" ]; then
    sudo rm -r "${QUAY_HOSTPATH}"
    sudo rm -r "${PSQL_HOSTPATH}"
  fi
  ;;
clean)
  [ -d "${QUAY_HOSTPATH}" ] && sudo rm -r "${QUAY_HOSTPATH}"
  [ -d "${PSQL_HOSTPATH}" ] && sudo rm -r "${PSQL_HOSTPATH}"
  ;;
ps)
  sudo podman ps -a
  ;;
*)
  usage
  ;;
esac

set +a
