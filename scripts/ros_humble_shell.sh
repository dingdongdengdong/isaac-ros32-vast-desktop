#!/usr/bin/env bash
set -e
source /opt/ros/humble/setup.bash
if [ -f "${ISAAC_ROS_WS:-/workspaces/isaac_ros-dev}/install/setup.bash" ]; then
  source "${ISAAC_ROS_WS:-/workspaces/isaac_ros-dev}/install/setup.bash"
fi
export RMW_IMPLEMENTATION="${RMW_IMPLEMENTATION:-rmw_cyclonedds_cpp}"
echo "ROS_DISTRO=$ROS_DISTRO"
echo "RMW_IMPLEMENTATION=$RMW_IMPLEMENTATION"
echo "ISAAC_ROS_WS=${ISAAC_ROS_WS:-/workspaces/isaac_ros-dev}"
exec bash
