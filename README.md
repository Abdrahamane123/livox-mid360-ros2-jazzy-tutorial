# Livox Mid-360 on Ubuntu 24.04 with ROS 2 Jazzy

This guide explains how to install, configure, and run a **Livox Mid-360** on **Ubuntu 24.04** with **ROS 2 Jazzy**.

## Tested Setup

- Ubuntu 24.04
- ROS 2 Jazzy
- Livox Mid-360
- Ethernet RJ45 connection

## Important Variables to Adapt

You must update these values for your own setup:

- **Ethernet interface name**  
  Example in this guide: `enp0s31f6`

- **PC static IP**  
  Example in this guide: `192.168.1.5`

- **LiDAR IP**  
  Livox Mid-360 usually uses an IP like:

  ```text
  192.168.1.1xx
  ```

  In many cases, `xx` matches the last two digits associated with the LiDAR serial shown on the box or label.

  Example used here:

  ```text
  192.168.1.109
  ```

- **Workspace path**  
  Example in this guide: `~/ws_livox`

---

## Scripts

Two helper scripts are available in the `scripts/` folder to speed up the setup.

### `scripts/install.sh`

Automates **steps 4 to 7** (dependencies, GCC 11, Livox-SDK2, workspace creation and driver clone).

```bash
chmod +x scripts/install.sh
./scripts/install.sh
```

> **Note:** This script does **not** configure `MID360_config.json` or build the driver.  
> You still need to complete steps 8 and 9 manually.

---

### `scripts/setup_network.sh`

Automates **step 2** (netplan static IP configuration and connectivity test).

> **Warning:** Before running this script, open it and adapt these three hardcoded values to your setup:
> - Ethernet interface name (default: `enp0s31f6`)
> - PC static IP (default: `192.168.1.5`)
> - LiDAR IP for the ping test (default: `192.168.1.109`)

```bash
chmod +x scripts/setup_network.sh
./scripts/setup_network.sh
```

---

### `config/MID360_config.json`

A reference configuration file is provided in the `config/` folder.  
Copy it to your driver config directory and adapt the IP addresses:

```bash
cp config/MID360_config.json ~/ws_livox/src/livox_ros_driver2/config/MID360_config.json
```

Then update `192.168.1.5` (PC IP) and `192.168.1.109` (LiDAR IP) as described in step 8.

---

## 1. Check the Ethernet Interface

```bash
ip link
```

Example result:

```text
enp0s31f6
```

---

## 2. Configure a Static IP

Create:

```bash
sudo nano /etc/netplan/01-livox.yaml
```

Example:

```yaml
network:
  version: 2
  ethernets:
    enp0s31f6:
      dhcp4: no
      addresses:
        - 192.168.1.5/24
```

Apply:

```bash
sudo netplan apply
```

Verify:

```bash
ip a
```

---

## 3. Check LiDAR Connectivity

Test the LiDAR IP:

```bash
ping 192.168.1.109
```

If you do not know the LiDAR IP, check the device label/box or scan the subnet:

```bash
sudo apt install -y nmap
nmap -sn 192.168.1.0/24
```

---

## 4. Install Dependencies

```bash
sudo apt update
sudo apt install -y \
  git \
  build-essential \
  cmake \
  libpcap-dev \
  libyaml-cpp-dev \
  python3-colcon-common-extensions
```

---

## 5. Install GCC 11 / G++ 11

On Ubuntu 24.04, **Livox-SDK2 may fail with the default compiler**.  
Installing and using **gcc-11 / g++-11** avoids many build errors.

```bash
sudo apt update
sudo apt install -y gcc-11 g++-11
```

---

## 6. Install Livox-SDK2

```bash
cd ~
git clone https://github.com/Livox-SDK/Livox-SDK2.git
cd ~/Livox-SDK2
rm -rf build
mkdir build
cd build
cmake .. -DCMAKE_C_COMPILER=gcc-11 -DCMAKE_CXX_COMPILER=g++-11
make -j$(nproc)
sudo make install
sudo ldconfig
```

Verify:

```bash
ls -l /usr/local/lib/liblivox_lidar_sdk_shared.so
```

---

## 7. Create the ROS 2 Workspace

```bash
mkdir -p ~/ws_livox/src
cd ~/ws_livox/src
git clone https://github.com/Livox-SDK/livox_ros_driver2.git
```

---

## 8. Configure the Mid-360

Edit:

```bash
nano ~/ws_livox/src/livox_ros_driver2/config/MID360_config.json
```

Example:

```json
{
  "lidar_summary_info": {
    "lidar_type": 8
  },
  "MID360": {
    "lidar_net_info": {
      "cmd_data_port": 56100,
      "push_msg_port": 56200,
      "point_data_port": 56300,
      "imu_data_port": 56400,
      "log_data_port": 56500
    },
    "host_net_info": {
      "cmd_data_ip": "192.168.1.5",
      "cmd_data_port": 56101,
      "push_msg_ip": "192.168.1.5",
      "push_msg_port": 56201,
      "point_data_ip": "192.168.1.5",
      "point_data_port": 56301,
      "imu_data_ip": "192.168.1.5",
      "imu_data_port": 56401,
      "log_data_ip": "192.168.1.5",
      "log_data_port": 56501
    }
  },
  "lidar_configs": [
    {
      "ip": "192.168.1.109",
      "pcl_data_type": 1,
      "pattern_mode": 0,
      "extrinsic_parameter": {
        "roll": 0.0,
        "pitch": 0.0,
        "yaw": 0.0,
        "x": 0.0,
        "y": 0.0,
        "z": 0.0
      }
    }
  ]
}
```

Update:
- `192.168.1.5` with your PC IP
- `192.168.1.109` with your LiDAR IP

---

## 9. Build the Driver

Use the provided build script:

```bash
cd ~/ws_livox/src/livox_ros_driver2
source /opt/ros/jazzy/setup.sh
./build.sh jazzy
```

Then source the workspace:

```bash
source ~/ws_livox/install/setup.bash
```

Optional:

```bash
echo "source ~/ws_livox/install/setup.bash" >> ~/.bashrc
source ~/.bashrc
```

---

## 10. Launch the Mid-360

For visualization in RViz2, use:

```bash
ros2 launch livox_ros_driver2 rviz_MID360_launch.py
```

This was the working command in this setup.

You can also verify the topics:

```bash
source /opt/ros/jazzy/setup.bash
source ~/ws_livox/install/setup.bash
ros2 topic list | grep livox
```

Example:

```text
/livox/imu
/livox/lidar
```

Check data rate:

```bash
ros2 topic hz /livox/lidar
```

---

## Common Issues

### `package.xml does not exist`
Use the provided script instead of a plain `colcon build`:

```bash
cd ~/ws_livox/src/livox_ros_driver2
./build.sh jazzy
```

### `Could not find LIVOX_LIDAR_SDK_LIBRARY`
Livox-SDK2 is not installed correctly. Verify:

```bash
ls -l /usr/local/lib/liblivox_lidar_sdk_shared.so
```

### SDK build errors on Ubuntu 24.04
Install and use GCC 11 / G++ 11:

```bash
sudo apt install -y gcc-11 g++-11
cmake .. -DCMAKE_C_COMPILER=gcc-11 -DCMAKE_CXX_COMPILER=g++-11
```

### LiDAR detected but no data published
Make sure the LiDAR IP in `MID360_config.json` matches the real device IP.

---

## Working Example

- Ethernet interface: `enp0s31f6`
- PC IP: `192.168.1.5`
- LiDAR IP: `192.168.1.109`
- Workspace: `~/ws_livox`

---

## Quick Start

If everything is already installed:

```bash
source /opt/ros/jazzy/setup.bash
source ~/ws_livox/install/setup.bash
ros2 launch livox_ros_driver2 rviz_MID360_launch.py
```

---

## References

- [Livox-SDK2](https://github.com/Livox-SDK/Livox-SDK2)
- [livox_ros_driver2](https://github.com/Livox-SDK/livox_ros_driver2)
- [ROS 2 Jazzy Documentation](https://docs.ros.org/en/jazzy/index.html)
