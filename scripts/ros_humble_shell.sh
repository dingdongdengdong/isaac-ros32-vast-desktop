#!/usr/bin/env bash
set -e
source /opt/ros/humble/setup.bash
if [ -f "${ROS_WS:-/workspaces/ros2_ws}/install/setup.bash" ]; then
  source "${ROS_WS:-/workspaces/ros2_ws}/install/setup.bash"
fi
export RMW_IMPLEMENTATION="${RMW_IMPLEMENTATION:-rmw_cyclonedds_cpp}"
echo "ROS_DISTRO=$ROS_DISTRO"
echo "RMW_IMPLEMENTATION=$RMW_IMPLEMENTATION"
echo "ROS_WS=${ROS_WS:-/workspaces/ros2_ws}"
exec bash
