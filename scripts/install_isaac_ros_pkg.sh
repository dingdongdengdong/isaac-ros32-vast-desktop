#!/usr/bin/env bash
set -e

if [ "$#" -lt 1 ]; then
  echo "Usage: install_isaac_ros_pkg.sh <package-name-without-ros-humble-prefix>"
  echo
  echo "Examples:"
  echo "  install_isaac_ros_pkg.sh isaac-ros-apriltag"
  echo "  install_isaac_ros_pkg.sh isaac-ros-visual-slam"
  echo
  echo "Available candidates:"
  apt-cache search ros-humble-isaac | head -80 || true
  exit 1
fi

PKG="ros-humble-$1"
sudo apt-get update
sudo apt-get install -y "$PKG"
