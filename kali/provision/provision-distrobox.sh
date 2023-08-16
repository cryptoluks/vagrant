#!/usr/bin/env bash

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  "$(. /etc/os-release && echo bullseye)" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin distrobox

usermod -a -G docker vagrant

su vagrant <<EOF
docker pull ghcr.io/cryptoluks/distroboxes/kali
EOF

tee /home/vagrant/.distroboxrc <<EOF
container_always_pull="0"
container_generate_entry="0"
container_manager="docker"
container_name_default="kali"
container_image_default="ghcr.io/cryptoluks/distroboxes/kali"
non_interactive="1"
EOF

chown vagrant:vagrant /home/vagrant/.distroboxrc