# 🐳 TRT-OpenCV-Dev

[![DOI](https://zenodo.org/badge/991382949.svg)](https://zenodo.org/badge/latestdoi/991382949)

**A [Docker](https://docs.docker.com/engine/install/ubuntu/) development environment for building high-performance C++ modules with [TensorRT](https://developer.nvidia.com/tensorrt) and [OpenCV](https://opencv.org/).**

Customizable Docker container with support for CUDA, cuDNN, TensorRT, OpenCV, and CMake — tailored for efficient deployment and development on NVIDIA GPUs.

## 📑 Citation

If you use this software, please use the GitHub **“Cite this repository”** button at the top(-right) of this page.


## Installation

Clone the repository and initialize submodules:

```bash
git clone --recurse-submodules https://github.com/HenrikTrom/Docker-OpenCV-TensorRT-Dev
git submodule update --init --remote --recursive
````

## 1: Configure `.env` Parameters

Edit the `.env` file in the root directory and set the following variables:

```env
UBUNTU_IMAGE_VERSION=22.04
CUDA_VERSION=12.3
TENSORRT_VERSION=8.6.1.6
CUDA_ARCH_BIN=8.6
OPENCV_VERSION=4.10.0
UID=1000         # id -u
GID=1000         # id -g
CMAKE_VERSION=3.28.0  # Must be >= 3.27.7
CPP_OPTIMIZATIONS="-O3 -march=native"
```

> **Important:**
> Ensure no conflicting environment variables are defined in your shell.
> Docker will override variables in your `.env` file if environment values exist.

---

## 2: Get TensorRT

1. Download the matching [TensorRT `.tar.gz` archive](https://developer.nvidia.com/tensorrt).

2. Place it in:

   ```
   ./build/vision_dependencies/tensorrt/
   ```

3. Verify that the file name matches the expected value in:

   ```
   ./build/vision_dependencies/tensorrt/install.sh
   ```

---

## 🧪 Tested with

* Ubuntu 20.04, CUDA 11.8, TensorRT 8.6.1.6, OpenCV 4.10.0
<!-- * Ubuntu 20.04, CUDA 12.3, TensorRT 10.6.1.6, OpenCV 4.10.0 -->
* Docker Engine 24+

