# Vast.ai Desktop + Isaac ROS 3.2 + ROS2 Humble

이 프로젝트는 Vast.ai의 Linux Desktop 컨테이너 이미지를 베이스로 해서 다음을 얹는 용도입니다.

- Ubuntu 22.04 / ROS2 Humble
- Isaac ROS 3.2 workspace scaffold
- NVIDIA Isaac ROS apt repository `release-3.2`
- Foxglove Bridge
- CycloneDDS
- Isaac Sim 5.1은 포함하지 않음. Vast 데스크탑 안에서 따로 설치하세요.

## 왜 이렇게 구성했나

Vast.ai 일반 Docker instance 안에서 다시 Docker를 띄우는 Docker-in-Docker 구조를 피하기 위해, ROS2/Isaac ROS/Foxglove를 하나의 top-level container 안에 설치합니다.

권장 운영:

```text
터미널 A: Isaac Sim 5.1 실행
- /opt/ros/humble/setup.bash source 하지 않음
- 필요 시 isaac_clean_shell.sh 사용

터미널 B: ROS2 / Isaac ROS / Foxglove 실행
- ros_humble_shell.sh 사용
- start_foxglove.sh 실행
```

## 1. Ubuntu 22.04 Vast desktop tag 확인

Vast/Linux Desktop의 정확한 Ubuntu 22.04 tag는 환경에 따라 다를 수 있습니다.

Dockerfile 기본값은 아래입니다.

```dockerfile
ARG BASE_IMAGE=vastai/linux-desktop:ubuntu22.04
```

이 tag가 없으면 Docker Hub 또는 Vast template에서 실제 Ubuntu 22.04 tag를 확인한 뒤 build argument로 넣으세요.

```bash
docker build \
  --build-arg BASE_IMAGE=vastai/linux-desktop:<UBUNTU_22_04_TAG> \
  -t <dockerhub-id>/isaac-ros32-desktop:ubuntu22 .
```

## 2. 빌드

Docker Hub 예시:

```bash
docker login

docker build \
  --build-arg BASE_IMAGE=vastai/linux-desktop:<UBUNTU_22_04_TAG> \
  -t <dockerhub-id>/isaac-ros32-desktop:ubuntu22 .

docker push <dockerhub-id>/isaac-ros32-desktop:ubuntu22
```

GHCR 예시:

```bash
docker login ghcr.io

docker build \
  --build-arg BASE_IMAGE=vastai/linux-desktop:<UBUNTU_22_04_TAG> \
  -t ghcr.io/<github-id>/isaac-ros32-desktop:ubuntu22 .

docker push ghcr.io/<github-id>/isaac-ros32-desktop:ubuntu22
```

## 3. Vast.ai Custom Template

기존 Vast `Linux Desktop` 템플릿을 복사해서 다음만 바꾸는 것을 추천합니다.

```text
Image Path:Tag = <dockerhub-id>/isaac-ros32-desktop:ubuntu22
```

기존 desktop template의 launch mode, env, entrypoint는 최대한 유지하세요.

추가 포트:

```bash
-p 8765:8765/tcp
```

Foxglove는 direct port보다 SSH tunnel이 더 안전합니다.

```bash
ssh -p <VAST_SSH_PORT> root@<VAST_IP> -L 8765:localhost:8765
```

Foxglove에서:

```text
ws://localhost:8765
```

## 4. 컨테이너 안에서 확인

```bash
verify_ros_gpu.sh
```

ROS shell:

```bash
ros_humble_shell.sh
```

Foxglove bridge:

```bash
start_foxglove.sh
```

Isaac Sim 실행용 clean shell:

```bash
isaac_clean_shell.sh
```

## 5. Isaac ROS 패키지 설치/빌드

기본 이미지에는 Isaac ROS Common workspace scaffold만 들어 있습니다.

사용 가능한 apt 패키지 확인:

```bash
apt-cache search ros-humble-isaac
```

예시:

```bash
sudo apt-get update
sudo apt-get install -y ros-humble-isaac-ros-apriltag
```

Source build 방식:

```bash
cd /workspaces/isaac_ros-dev/src
# 필요한 Isaac ROS repo clone
# 예: git clone -b release-3.2 https://github.com/NVIDIA-ISAAC-ROS/isaac_ros_apriltag.git

cd /workspaces/isaac_ros-dev
build_isaac_ros_ws.sh
```

## 주의

- Isaac ROS 3.2는 Ubuntu 22.04 / ROS2 Humble 계열에 맞습니다.
- Isaac ROS 4.x는 Ubuntu 24.04 / Jazzy 계열입니다.
- Isaac Sim 5.1은 Python 3.11 기반이므로 ROS2 Humble Python 3.10 환경과 한 터미널에서 섞지 마세요.
- Isaac Sim 실행용 터미널과 ROS2/Isaac ROS 실행용 터미널을 분리하세요.
