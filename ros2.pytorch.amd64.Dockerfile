################################
# BASE IMAGE
################################

ARG BASE_IMAGE
FROM $BASE_IMAGE AS base

ENV DEBIAN_FRONTEND=noninteractive

# install common tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo \
    curl \
    ca-certificates \
    gnupg \
    lsb-release \
    python3-pip \
    wget \
    zip \
    git \
    libglvnd0 \
    libgl1 \
    libglx0 \
    libegl1 \
    libxext6 \
    libx11-6 \
    && rm -rf /var/lib/apt/lists/*

# install ROS2
ARG ROS_DISTRO

RUN apt-get update && apt-get install -y \
  locales \
  && locale-gen en_US.UTF-8 \
  && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 \
  && rm -rf /var/lib/apt/lists/*
ENV LANG=en_US.UTF-8

# Install timezone
RUN ln -fs /usr/share/zoneinfo/UTC /etc/localtime \
  && export DEBIAN_FRONTEND=noninteractive \
  && apt-get update \
  && apt-get install -y tzdata \
  && dpkg-reconfigure --frontend noninteractive tzdata \
  && rm -rf /var/lib/apt/lists/*

RUN sudo apt-get update \
    && sudo apt-get install -y software-properties-common \
    && sudo add-apt-repository universe

RUN sudo apt-get update \
    && sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null \
    && sudo apt-get update \
    && sudo apt-get install -y \
        ros-$ROS_DISTRO-ros-base \
    && rm -rf /var/lib/apt/lists/* 

# Install pytorch and torchvision
RUN pip3 install \
    --index-url https://download.pytorch.org/whl/cu121 \
    torch==2.3.0 \
    torchvision==0.18.0

# Install tensorrt
ARG TRT_VERSION=10.5.0
ARG TRT_CUDA_VERSION=12.6

RUN sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/3bf863cc.pub &&\
    sudo apt-get update &&\
    sudo apt-get install -y \
      python3-libnvinfer-dev &&\
    python3 -m pip install \
      onnx \
      onnx-graphsurgeon \
      pycuda      
