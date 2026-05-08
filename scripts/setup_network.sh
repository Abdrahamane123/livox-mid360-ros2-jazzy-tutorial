#!/bin/bash
# Network configuration for Livox Mid-360
sudo bash -c 'cat > /etc/netplan/01-livox.yaml << EOL
network:
  version: 2
  ethernets:
    enp0s31f6:
      dhcp4: no
      addresses:
        - 192.168.1.5/24
EOL'
sudo netplan apply
echo "Network configured. Testing connection..."
ping -c 3 192.168.1.109
