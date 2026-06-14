#!/usr/bin/env bash
set -e
source /opt/ros/humble/setup.bash
if [ -f "${ISAAC_ROS_WS:-/workspaces/isaac_ros-dev}/install/setup.bash" ]; then
  source "${ISAAC_ROS_WS:-/workspaces/isaac_ros-dev}/install/setup.bash"
fi
export RMW_IMPLEMENTATION="${RMW_IMPLEMENTATION:-rmw_cyclonedds_cpp}"
PORT="${FOXGLOVE_PORT:-8765}"
echo "Starting Foxglove Bridge on 0.0.0.0:${PORT}"
exec ros2 launch foxglove_bridge foxglove_bridge_launch.xml port:="${PORT}" address:=0.0.0.0
