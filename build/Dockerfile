ARG UBUNTU_IMAGE_VERSION
ARG CUDA_VERSION=12.3

FROM nvidia/cuda:${CUDA_VERSION}-devel-ubuntu${UBUNTU_IMAGE_VERSION} AS opencv_trt_dev

LABEL maintainer="Henrik Trommer <henrik.trommer@uni-goettingen.de>"

SHELL ["/bin/bash","-c"]

# Set system timezone to UTC
RUN echo 'Etc/UTC' > /etc/timezone && \
    ln -s /usr/share/zoneinfo/Etc/UTC /etc/localtime && \
    apt-get update && \
    apt-get install -q -y --no-install-recommends tzdata && \
    rm -rf /var/lib/apt/lists/*

# Install GPG and certificate tools for adding external repositories
RUN apt update && apt install -q -y --no-install-recommends \
    dirmngr \
    gnupg2 \
    && rm -rf /var/lib/apt/lists/*

################################################################
# Essential build tools and dependencies
################################################################

# Install build tools and software properties
RUN apt update && apt install --no-install-recommends -y \
    software-properties-common \
    build-essential

# Install common development libraries and utilities
RUN apt update --fix-missing && apt install --no-install-recommends -y \
    wget git bzip2 ca-certificates zlib1g-dev \
    libncurses5-dev libgdbm-dev libglib2.0-0 libxext6 libsm6 \
    libxrender1 libffi-dev libusb-1.0-0-dev \
    && rm -rf /var/lib/apt/lists/*

# Install additional helpful CLI tools and math libraries
RUN apt update && apt install --no-install-recommends -y \
    tree nano libeigen3-dev

################################################################
## Python Environment Setup
################################################################

# Install Python and pip
RUN apt update && apt install --no-install-recommends -y \
    python3 \
    python3-pip

# Install core AI/ML and inference libraries
RUN pip install ultralytics onnx onnxruntime-gpu

# Install numerical and visualization packages
RUN pip3 install numpy==1.24.4 scipy pandas tqdm seaborn python-chess cairosvg
RUN pip3 install opencv-contrib-python
RUN pip3 install scikit-learn scikit-image matplotlib pillow jsonpickle rich

################################################################
## X11 and debugging utilities
################################################################

# Enable X11 forwarding and archive tools
RUN apt-get update -y && apt-get install -y \
    x11-apps xauth zip

# Install multimedia, JSON, debugging, and system tools
RUN apt -y install ffmpeg libavdevice-dev rapidjson-dev gdb
RUN apt -y install zlib1g unzip mlocate
RUN apt -y install usbutils pciutils htop iputils-ping

# Install sudo for non-root user
RUN apt update && apt install --no-install-recommends -y sudo

################################################################
## CMake Installation (custom version)
################################################################

ARG CMAKE_VERSION
ENV CMAKE_VERSION=${CMAKE_VERSION}

# Install custom version of CMake
RUN apt-get update && apt-get install -y wget curl ca-certificates \
    && wget https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-linux-x86_64.sh \
    && mkdir /opt/cmake \
    && sh cmake-${CMAKE_VERSION}-linux-x86_64.sh --skip-license --prefix=/opt/cmake \
    && ln -s /opt/cmake/bin/cmake /usr/local/bin/cmake \
    && rm cmake-${CMAKE_VERSION}-linux-x86_64.sh

# Additional dependencies for logging and formatting
RUN apt -y install libspdlog-dev libfmt-dev 

################################################################
## Vision Dependencies Installation
################################################################

# Re-declare args as they're not preserved after `FROM`
ARG TENSORRT_VERSION
ARG UBUNTU_IMAGE_VERSION
ARG CUDA_VERSION
ARG CUDA_ARCH_BIN
ARG OPENCV_VERSION
ARG UID
ARG GID
ARG CPP_OPTIMIZATIONS

# Export args as environment variables
ENV UBUNTU_IMAGE_VERSION=${UBUNTU_IMAGE_VERSION}
ENV CUDA_VERSION=${CUDA_VERSION}
ENV TENSORRT_VERSION=${TENSORRT_VERSION}
ENV CUDA_ARCH_BIN=${CUDA_ARCH_BIN}
ENV OPENCV_VERSION=${OPENCV_VERSION}
ENV CPP_OPTIMIZATIONS=${CPP_OPTIMIZATIONS}

# Copy and install vision-related dependencies (OpenCV, TensorRT, cuDNN)
RUN mkdir /opt/vision_dependencies
# Install cuDNN
RUN apt install -y libcudnn8 libcudnn8-dev
# RUN if [[ "$TENSORRT_VERSION" == 8* ]]; then apt install -y libcudnn8 libcudnn8-dev; \
#     else apt install -y libcudnn9 libcudnn9-dev; \
#     fi
################################################################
# OpenCV and TensorRT Installation
################################################################
COPY ./vision_dependencies/ /opt/vision_dependencies/

# Install OpenCV (custom build)
WORKDIR /opt/vision_dependencies/opencv/
RUN chmod +x install.sh && ./install.sh

# Install TensorRT
WORKDIR /opt/vision_dependencies/tensorrt/
RUN chmod +x install.sh && ./install.sh

################################################################
## System Fixes and Quality of Life Improvements
################################################################

# Workaround for broken APT cache cleanup in some base images
RUN rm /etc/apt/apt.conf.d/docker-clean &&\
    apt-get update

# Enable case-insensitive tab completion
RUN echo 'set completion-ignore-case On' >> /etc/inputrc

################################################################
## Final Setup: User Environment and Permissions
################################################################

# Create non-root user with sudo permissions
COPY ./setup/user.sh /tmp/user.sh
RUN chmod +x /tmp/user.sh && /tmp/user.sh

# Set default workspace
WORKDIR /home/docker/modules

# Add custom shell configuration
COPY .bashrc /home/docker/.bashrc

# Remove potentially conflicting OpenCV libraries from system
RUN rm -rf /usr/lib/x86_64-linux-gnu/libopencv*
RUN rm -rf /usr/lib/x86_64-linux-gnu/cmake/opencv4/

# Update file search database
RUN updatedb

# Switch to non-root user
USER docker
