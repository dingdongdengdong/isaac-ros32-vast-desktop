# Vast.ai Ubuntu 22.04 base + lightweight desktop + ROS2 Humble + Isaac ROS 3.2 scaffold
#
# Isaac Sim is intentionally NOT installed here. Install Isaac Sim 5.1 manually later.
# This image prepares Ubuntu 22.04, CUDA-capable Vast base, XFCE/noVNC desktop,
# ROS2 Humble, Isaac ROS 3.2 workspace scaffold, Foxglove bridge, and helper scripts.

ARG BASE_IMAGE=vastai/base-image:cuda-12.8.1-cudnn-devel-ubuntu22.04
FROM ${BASE_IMAGE}

SHELL ["/bin/bash", "-lc"]

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV ROS_DISTRO=humble
ENV ISAAC_ROS_RELEASE=release-3.2
ENV ISAAC_ROS_WS=/workspaces/isaac_ros-dev
ENV RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
ENV DISPLAY=:1
ENV RESOLUTION=1920x1080x24

# Sanity check: this Dockerfile is designed for Ubuntu 22.04 / jammy.
RUN source /etc/os-release && \
    echo "Detected Ubuntu codename: ${VERSION_CODENAME}" && \
    test "${VERSION_CODENAME}" = "jammy"

# Base tools + lightweight desktop/noVNC stack
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
    supervisor \
    dbus-x11 \
    x11-xserver-utils \
    xvfb \
    x11vnc \
    novnc \
    websockify \
    xfce4 \
    xfce4-terminal \
    && locale-gen en_US en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

# Lightweight desktop launcher. Vast base-image normally boots supervisord;
# this supervisor program makes noVNC available on 6080 and VNC on 5900.
RUN cat <<'EOF' >/usr/local/bin/start_desktop.sh
#!/usr/bin/env bash
set -euo pipefail
export DISPLAY="${DISPLAY:-:1}"
RESOLUTION="${RESOLUTION:-1920x1080x24}"

if ! pgrep -f "Xvfb ${DISPLAY}" >/dev/null 2>&1; then
  Xvfb "${DISPLAY}" -screen 0 "${RESOLUTION}" -ac +extension GLX +render -noreset &
fi

sleep 2

if ! pgrep -f "xfce4-session" >/dev/null 2>&1; then
  startxfce4 &
fi

sleep 2

if ! pgrep -f "x11vnc.*${DISPLAY}" >/dev/null 2>&1; then
  x11vnc -display "${DISPLAY}" -forever -shared -nopw -listen 0.0.0.0 -rfbport 5900 -xkb &
fi

exec websockify --web=/usr/share/novnc/ 0.0.0.0:6080 localhost:5900
EOF
RUN chmod +x /usr/local/bin/start_desktop.sh && \
    mkdir -p /etc/supervisor/conf.d && \
    cat <<'EOF' >/etc/supervisor/conf.d/desktop.conf
[program:desktop]
command=/usr/local/bin/start_desktop.sh
autostart=true
autorestart=true
startsecs=5
stdout_logfile=/var/log/desktop.log
stderr_logfile=/var/log/desktop.err
EOF

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

# Helpful shell setup. Do NOT source ROS globally for every shell if you plan to launch Isaac Sim.
RUN cat <<'EOF' >/etc/profile.d/isaac_ros32_vast.sh
export ISAAC_ROS_WS="${ISAAC_ROS_WS:-/workspaces/isaac_ros-dev}"
export RMW_IMPLEMENTATION="${RMW_IMPLEMENTATION:-rmw_cyclonedds_cpp}"
alias rosenv='source /opt/ros/humble/setup.bash && [ -f "$ISAAC_ROS_WS/install/setup.bash" ] && source "$ISAAC_ROS_WS/install/setup.bash" || true'
alias foxglove='start_foxglove.sh'
alias verify_ros='verify_ros_gpu.sh'
EOF

EXPOSE 5900 6080 8765

WORKDIR /workspaces
