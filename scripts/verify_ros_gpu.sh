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
echo "=== ROS2 workspace ==="
echo "${ROS_WS:-/workspaces/ros2_ws}"
ls -la "${ROS_WS:-/workspaces/ros2_ws}/src" || true

echo
echo "=== Foxglove Bridge ==="
ros2 pkg prefix foxglove_bridge || true

echo
echo "Done."
