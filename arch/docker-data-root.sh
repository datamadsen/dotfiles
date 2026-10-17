#!/usr/bin/env bash
#
# Move Docker's data (images, containers, volumes) off the root partition.
#
# Root is a 50 GB LUKS partition and /home is the big one, so Docker's
# data-root goes to /home/docker. Installs docker/daemon.json as
# /etc/docker/daemon.json, copies /var/lib/docker over once, and restarts
# Docker. Safe to rerun: a second run only reinstalls daemon.json.
#
# After checking that `docker images` still lists everything, free the
# old copy with:  sudo rm -rf /var/lib/docker
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OLD=/var/lib/docker
NEW=/home/docker

echo "[docker] installing /etc/docker/daemon.json (data-root $NEW)"
sudo install -D -m 644 "$SCRIPT_DIR/docker/daemon.json" /etc/docker/daemon.json

if [[ -e $NEW ]]; then
  echo "[docker] $NEW already exists; not copying"
elif [[ -d $OLD ]]; then
  echo "[docker] stopping docker (running containers restart afterwards)"
  sudo systemctl stop docker.socket docker.service
  echo "[docker] copying $OLD to $NEW"
  sudo cp -a "$OLD" "$NEW"
else
  sudo mkdir -p "$NEW"
fi

echo "[docker] starting docker"
sudo systemctl start docker.service
echo "[docker] data root is now: $(docker info --format '{{.DockerRootDir}}')"
docker images --format '  {{.Repository}}:{{.Tag}}'
echo "[docker] once that list looks right: sudo rm -rf $OLD"
