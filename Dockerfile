# Vast.ai Linux Desktop + ROS2 Humble + Isaac ROS 3.2 scaffold
#
# Build example:
#   docker build \
#     --build-arg BASE_IMAGE=vastai/linux-desktop:<UBUNTU_22_04_TAG> \
#     -t <dockerhub-id>/isaac-ros32-desktop:ubuntu22 .
#
# NOTE:
# - BASE_IMAGE must be Ubuntu 22.04 / jammy.
# - Isaac Sim is intentionally NOT installed here. Install Isaac Sim 5.1 manually inside the desktop later.
# - This image prepares ROS2 Humble, Isaac ROS 3.2 workspace scaffold, Foxglove bridge, and helper scripts.

ARG BASE_IMAGE=vastai/linux-desktop:ubuntu22.04
FROM ${BASE_IMAGE}

SHELL ["/bin/bash", "-lc"]

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV ROS_DISTRO=humble
ENV ISAAC_ROS_RELEASE=release-3.2
ENV ISAAC_ROS_WS=/workspaces/isaac_ros-dev
ENV RMW_IMPLEMENTATION=rmw_cyclonedds_cpp

# Sanity check: this Dockerfile is designed for Ubuntu 22.04 / jammy.
RUN source /etc/os-release && \
    echo "Detected Ubuntu codename: ${VERSION_CODENAME}" && \
    test "${VERSION_CODENAME}" = "jammy"

# Base tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    locales \
    curl \
    wget \
    git \
    gnupg \
    ca-certificates \
    lsb-release \
    software-properties-common \
    sudo \
    nano \
    vim \
    tmux \
    htop \
    pciutils \
    usbutils \
    build-essential \
    cmake \
    python3-pip \
    python3-venv \
    python3-dev \
    python3-colcon-common-extensions \
    python3-rosdep \
    python3-vcstool \
    python3-argcomplete \
    && locale-gen en_US en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

# ROS2 Humble apt repository
RUN add-apt-repository universe -y && \
    curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
      -o /usr/share/keyrings/ros-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu jammy main" \
      > /etc/apt/sources.list.d/ros2.list && \
    apt-get update && apt-get install -y --no-install-recommends \
      ros-humble-ros-base \
      ros-humble-demo-nodes-cpp \
      ros-humble-demo-nodes-py \
      ros-humble-rmw-cyclonedds-cpp \
      ros-humble-cyclonedds \
      ros-humble-foxglove-bridge \
      ros-humble-vision-msgs \
      ros-humble-image-transport \
      ros-humble-cv-bridge \
      ros-humble-tf2-ros \
      ros-humble-tf-transformations \
      ros-humble-rviz2 \
      ros-humble-nav2-msgs \
      ros-humble-diagnostic-updater \
      && rm -rf /var/lib/apt/lists/*

# NVIDIA Isaac ROS apt repository for release-3.2 on Ubuntu 22.04 / jammy.
# This enables apt-search/install for Isaac ROS Debian packages where available.
RUN k="/usr/share/keyrings/nvidia-isaac-ros.gpg" && \
    curl -fsSL https://isaac.download.nvidia.com/isaac-ros/repos.key | gpg --dearmor | tee "$k" > /dev/null && \
    f="/etc/apt/sources.list.d/nvidia-isaac-ros.list" && \
    s="deb [signed-by=$k] https://isaac.download.nvidia.com/isaac-ros/release-3.2 jammy main" && \
    echo "$s" > "$f" && \
    apt-get update || true

# rosdep setup
RUN rosdep init || true && rosdep update || true

# Isaac ROS workspace scaffold
RUN mkdir -p ${ISAAC_ROS_WS}/src && \
    cd ${ISAAC_ROS_WS}/src && \
    git clone --branch ${ISAAC_ROS_RELEASE} --depth 1 https://github.com/NVIDIA-ISAAC-ROS/isaac_ros_common.git

# Add helper scripts
COPY scripts/*.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/*.sh

# Helpful shell setup. Do NOT source ROS globally for every shell if you plan to launch Isaac Sim
# from the same shell. Use ros_humble_shell for ROS work and isaac_clean_shell for Isaac Sim.
RUN cat <<'EOF' >/etc/profile.d/isaac_ros32_vast.sh
export ISAAC_ROS_WS="${ISAAC_ROS_WS:-/workspaces/isaac_ros-dev}"
export RMW_IMPLEMENTATION="${RMW_IMPLEMENTATION:-rmw_cyclonedds_cpp}"
alias rosenv='source /opt/ros/humble/setup.bash && [ -f "$ISAAC_ROS_WS/install/setup.bash" ] && source "$ISAAC_ROS_WS/install/setup.bash" || true'
alias foxglove='start_foxglove.sh'
alias verify_ros='verify_ros_gpu.sh'
EOF

WORKDIR /workspaces

CMD ["/bin/bash"]
