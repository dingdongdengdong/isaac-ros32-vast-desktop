#!/usr/bin/env bash
# Use this shell before launching Isaac Sim 5.1.
# It avoids accidentally mixing system ROS2 Humble Python 3.10 env with Isaac Sim Python 3.11.
unset ROS_DISTRO
unset ROS_VERSION
unset ROS_PYTHON_VERSION
unset AMENT_PREFIX_PATH
unset COLCON_PREFIX_PATH
unset CMAKE_PREFIX_PATH
unset PYTHONPATH
unset LD_LIBRARY_PATH
echo "Clean shell for Isaac Sim."
echo "Do not source /opt/ros/humble/setup.bash here."
exec bash
