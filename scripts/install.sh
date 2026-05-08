#!/bin/bash
# Installation script for Livox Mid-360 on ROS 2 Jazzy
set -e

echo "Installing dependencies..."
sudo apt update
sudo apt install -y git build-essential cmake libpcap-dev libyaml-cpp-dev python3-colcon-common-extensions gcc-11 g++-11

echo "Cloning and building Livox-SDK2..."
cd ~
git clone https://github.com/Livox-SDK/Livox-SDK2.git
cd Livox-SDK2
mkdir -p build && cd build
cmake .. -DCMAKE_C_COMPILER=gcc-11 -DCMAKE_CXX_COMPILER=g++-11
make -j$(nproc)
sudo make install
sudo ldconfig

echo "Setting up workspace..."
mkdir -p ~/ws_livox/src
cd ~/ws_livox/src
git clone https://github.com/Livox-SDK/livox_ros_driver2.git

echo "Installation complete!"
