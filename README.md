# Livox Mid-360 with ROS 2 Jazzy on Ubuntu 24.04

This guide documents the working setup for a **Livox Mid-360** on **Ubuntu 24.04** with **ROS 2 Jazzy**.

## Tested Setup

- Ubuntu 24.04
- ROS 2 Jazzy
- Livox Mid-360
- PC Ethernet IP: `192.168.1.5`
- LiDAR IP: `192.168.1.109`
- Ethernet interface: `enp0s31f6`

---

## 1. Configure the Ethernet interface

Create a Netplan config:

```bash
sudo nano /etc/netplan/01-livox.yaml
```

```yaml
network:
  version: 2
  ethernets:
    enp0s31f6:
      dhcp4: no
      addresses:
        - 192.168.1.5/24
```

Apply it:

```bash
sudo netplan apply
```

Verify connectivity:

```bash
ping 192.168.1.109
```

---

## 2. Install dependencies

```bash
sudo apt update
sudo apt install -y \
  git \
  build-essential \
  cmake \
  libpcap-dev \
  libyaml-cpp-dev \
  python3-colcon-common-extensions \
  gcc-11 \
  g++-11
```

---

## 3. Install Livox-SDK2

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

Check installation:

```bash
ls -l /usr/local/lib/liblivox_lidar_sdk_shared.so
```

---

## 4. Install livox_ros_driver2

```bash
mkdir -p ~/ws_livox/src
cd ~/ws_livox/src
git clone https://github.com/Livox-SDK/livox_ros_driver2.git
```

Edit the config file:

```bash
nano ~/ws_livox/src/livox_ros_driver2/config/MID360_config.json
```

Use this working configuration:

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

Build the driver:

```bash
cd ~/ws_livox/src/livox_ros_driver2
source /opt/ros/jazzy/setup.sh
./build.sh jazzy
```

Source the workspace:

```bash
source ~/ws_livox/install/setup.bash
```

---

## 5. Run the LiDAR

Check topics:

```bash
ros2 topic list | grep livox
```

Check publish rate:

```bash
ros2 topic hz /livox/lidar
```

Launch with RViz2:

```bash
source /opt/ros/jazzy/setup.bash
source ~/ws_livox/install/setup.bash
ros2 launch livox_ros_driver2 rviz_MID360_launch.py
```

---

## Notes

- `msg_MID360_launch.py` runs the driver, but `rviz_MID360_launch.py` is the working launch file for visualization.
- On Ubuntu 24.04, `Livox-SDK2` may fail with the default compiler. Building with **gcc-11/g++-11** fixed the issue.
- If logs show `found lidar not defined in the user-defined config`, verify the LiDAR IP in `MID360_config.json`.

---

## References

- [Livox-SDK2](https://github.com/Livox-SDK/Livox-SDK2)
- [livox_ros_driver2](https://github.com/Livox-SDK/livox_ros_driver2)