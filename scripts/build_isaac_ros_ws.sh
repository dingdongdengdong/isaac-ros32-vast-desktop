#!/usr/bin/env bash
set -e
WS="${ISAAC_ROS_WS:-/workspaces/isaac_ros-dev}"
source /opt/ros/humble/setup.bash
export RMW_IMPLEMENTATION="${RMW_IMPLEMENTATION:-rmw_cyclonedds_cpp}"

cd "$WS"
echo "Installing dependencies with rosdep..."
rosdep update || true
rosdep install -i --from-path src --rosdistro humble -y || true

echo "Building workspace..."
colcon build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=Release

echo "Build complete."
echo "Source with:"
echo "  source $WS/install/setup.bash"
