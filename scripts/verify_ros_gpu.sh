#!/usr/bin/env bash
set -e

echo "=== OS ==="
cat /etc/os-release || true

echo
echo "=== GPU ==="
nvidia-smi || true

echo
echo "=== CUDA files ==="
ls -la /usr/local/cuda* 2>/dev/null || true

echo
echo "=== ROS2 ==="
source /opt/ros/humble/setup.bash
ros2 --help >/dev/null
echo "ROS2 OK: ${ROS_DISTRO}"

echo
echo "=== RMW ==="
export RMW_IMPLEMENTATION="${RMW_IMPLEMENTATION:-rmw_cyclonedds_cpp}"
echo "RMW_IMPLEMENTATION=${RMW_IMPLEMENTATION}"

echo
echo "=== Isaac ROS workspace ==="
echo "${ISAAC_ROS_WS:-/workspaces/isaac_ros-dev}"
ls -la "${ISAAC_ROS_WS:-/workspaces/isaac_ros-dev}/src" || true

echo
echo "=== Isaac ROS apt packages available? ==="
apt-cache search ros-humble-isaac | head -50 || true

echo
echo "Done."
