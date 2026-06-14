#!/usr/bin/env bash
set -e
WS="${ROS_WS:-/workspaces/ros2_ws}"
source /opt/ros/humble/setup.bash
export RMW_IMPLEMENTATION="${RMW_IMPLEMENTATION:-rmw_cyclonedds_cpp}"

mkdir -p "$WS/src"
cd "$WS"

echo "Installing dependencies with rosdep..."
rosdep update || true
rosdep install -i --from-path src --rosdistro humble -y || true

echo "Building ROS2 workspace..."
colcon build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=Release

echo "Build complete."
echo "Source with:"
echo "  source $WS/install/setup.bash"
