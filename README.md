# Vast.ai Desktop + ROS2 Humble + Foxglove

This project builds a Vast.ai-friendly Docker image for running ROS2 Humble and Foxglove on a cheap GPU instance.

It intentionally does **not** include Isaac ROS and does **not** include Isaac Sim.

Included:

- Ubuntu 22.04 / ROS2 Humble
- Vast.ai CUDA-capable base image
- Lightweight XFCE desktop
- VNC on `5900`
- noVNC on `6080`
- Foxglove Bridge on `8765`
- rosbridge on `9090` if you choose to use it
- CycloneDDS
- Helper scripts

Not included:

- Isaac ROS
- Isaac Sim 5.1
- Isaac Sim WebRTC / UDP setup

## Architecture

Recommended runtime layout:

```text
same Vast container
├── Isaac Sim 5.1 installed manually later in /workspace/isaacsim
├── ROS2 Humble installed in this image
├── your ROS2 workspace at /workspaces/ros2_ws
├── Foxglove Bridge on 8765/TCP
└── desktop/noVNC for GUI access
```

Recommended terminal split:

```text
Terminal A: Isaac Sim 5.1
- use isaac_clean_shell.sh
- do not source /opt/ros/humble/setup.bash here

Terminal B: ROS2 / Foxglove
- use ros_humble_shell.sh
- run start_foxglove.sh
```

## Build image

Default base image:

```dockerfile
ARG BASE_IMAGE=vastai/base-image:cuda-12.8.1-cudnn-devel-ubuntu22.04
```

GHCR target image:

```text
ghcr.io/dingdongdengdong/isaac-ros32-desktop:ubuntu22
```

The name still says `isaac-ros32-desktop` for continuity, but the image is now ROS2 Humble only. You may rename the workflow input to something like `ros2-humble-vast-desktop` if desired.

## GitHub Actions build

Go to:

```text
Actions
→ Build and push Docker image to GHCR
→ Run workflow
```

Use default values:

```text
base_image: vastai/base-image:cuda-12.8.1-cudnn-devel-ubuntu22.04
image_name: isaac-ros32-desktop
```

Expected output:

```text
ghcr.io/dingdongdengdong/isaac-ros32-desktop:ubuntu22
```

## Vast.ai Custom Template

Use the built GHCR image as the image path:

```text
ghcr.io/dingdongdengdong/isaac-ros32-desktop:ubuntu22
```

Recommended Docker Options:

```bash
-p 5900:5900/tcp \
-p 6080:6080/tcp \
-p 8765:8765/tcp \
-p 9090:9090/tcp
```

Port meaning:

```text
5900  VNC
6080  noVNC web desktop
8765  Foxglove Bridge
9090  rosbridge websocket, optional
```

Foxglove through SSH tunnel is still recommended:

```bash
ssh -p <VAST_SSH_PORT> root@<VAST_IP> -L 8765:localhost:8765
```

Then connect Foxglove to:

```text
ws://localhost:8765
```

## Container commands

Verify ROS/GPU:

```bash
verify_ros_gpu.sh
```

Open ROS2 shell:

```bash
ros_humble_shell.sh
```

Start Foxglove Bridge:

```bash
start_foxglove.sh
```

Open clean shell for Isaac Sim:

```bash
isaac_clean_shell.sh
```

Build your ROS2 workspace:

```bash
build_ros2_ws.sh
```

## Isaac Sim note

Isaac Sim 5.1 is best installed manually later inside `/workspace` or an attached Vast volume, for example:

```text
/workspace/isaacsim
/workspace/ros2_ws
/workspace/data
```

This avoids rebuilding a huge Docker image whenever Isaac Sim changes. Isaac Sim 5.1 uses Python 3.11, while ROS2 Humble on Ubuntu 22.04 uses Python 3.10, so keep Isaac Sim and ROS2 shells separate.
