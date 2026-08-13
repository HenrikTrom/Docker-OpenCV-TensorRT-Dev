# Docker OpenCV TensorRT Dev

[![DOI](https://zenodo.org/badge/991382949.svg)](https://zenodo.org/badge/latestdoi/991382949)

This repository builds a Docker-based development environment for C++ projects that depend on CUDA, cuDNN, TensorRT, OpenCV, and CMake. It is intended for local development on Linux hosts with NVIDIA GPUs.

The repository also vendors related C++ projects in `modules/` as Git submodules.

## Contents

- `build/Dockerfile`: main development image
- `build/Dockerfile.ros2`: ROS 2 extension image
- `docker-compose.yaml`: long-running dev container with GPU access and a bind mount of the workspace
- `modules/`: related C++ libraries and applications

## Requirements

- Linux host
- Docker Engine with Compose support
- NVIDIA driver working on the host
- NVIDIA Container Toolkit
- A TensorRT archive that matches the versions configured in `.env`

Check the host driver before building anything:

```bash
nvidia-smi
```

## Setup

Clone the repository and initialize submodules:

```bash
git clone --recurse-submodules https://github.com/HenrikTrom/Docker-OpenCV-TensorRT-Dev
cd Docker-OpenCV-TensorRT-Dev
git submodule update --init --remote --recursive
```

Review `.env`. The main variables you will usually care about are:

```env
UBUNTU_IMAGE_VERSION=24.04
CUDA_VERSION=12.9.2
TENSORRT_VERSION=10.14.1.48
CUDA_ARCH_BIN=8.6
OPENCV_VERSION=4.13.0
UID=1000
GID=1000
TAG1=opencv-trt-dev
TAG2=opencv-trt-ros2-dev
ROS_DISTRO=jazzy
CMAKE_VERSION=3.27.7
CPP_OPTIMIZATIONS="-DNDEBUG -O3 -Wno-deprecated-declarations"
```

Docker will prefer environment variables already present in your shell over values in `.env`, so avoid exporting conflicting values unless that is intentional.

Place the matching TensorRT archive in:

```text
./build/vision_dependencies/tensorrt/
```

The install script accepts either the expected `.tar.gz` archive or the NVIDIA `.tar.tar` naming used by some downloads.

Build and start the container:

```bash
docker compose up -d --build
```

Verify GPU access inside the container:

```bash
docker exec -it "${TAG1}" nvidia-smi
```

## GPU Runtime Notes

There are two different failure modes worth distinguishing:

1. Host driver failure
   `nvidia-smi` fails on the host and inside the container. Fix the host first.

2. Container-only GPU dropout
   `nvidia-smi` keeps working on the host but later fails inside a long-running container with `Failed to initialize NVML: Unknown Error`.

The second case is a known NVIDIA Container Toolkit issue in some Docker/`runc`/`systemd` cgroup setups. This repository mitigates it by explicitly mapping the NVIDIA device nodes in `docker-compose.yaml`.

If a running container loses GPU access, recreate it:

```bash
docker compose down
docker compose up -d --build
```

If the issue persists, check whether Docker is using `Cgroup Driver: systemd`:

```bash
docker info
```

NVIDIA documents two stronger mitigations for affected hosts:

- switch Docker to `cgroupfs`
- use NVIDIA CDI instead of the legacy hook-based `gpus: all` path

## Tested Configurations

- Ubuntu 20.04, CUDA 11.8, TensorRT 8.6.1.6, OpenCV 4.10.0
- Ubuntu 20.04, CUDA 12.3, TensorRT 10.6.1.6, OpenCV 4.10.0
- Ubuntu 24.04, CUDA 12.9, TensorRT 10.14.1.48, OpenCV 4.13.0
- Docker Engine 24+

## Citation

If you use this repository in academic work, use the GitHub "Cite this repository" entry.
