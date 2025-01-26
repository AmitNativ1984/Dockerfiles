################################
# BASE IMAGE
################################

ARG BASE_IMAGE=nvcr.io/nvidia/cuda:12.6.3-cudnn-devel-ubuntu22.04
FROM $BASE_IMAGE AS base

ENV SHELL /bin/bash
SHELL [ "/bin/bash", "-c" ]

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
    libopenmpi-dev \
    libopenblas-base \
    libomp-dev \
    && rm -rf /var/lib/apt/lists/*

# #################################
# ### INSTALL ROS 2 ###############
# #################################
ARG ROS_DISTRO=humble

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

# Install pytorch
# links found on: https://pypi.jetson-ai-lab.dev/jp6
RUN pip3 install \
    numpy=='1.26.1' \
    # torch
    https://pypi.jetson-ai-lab.dev/jp6/cu124/+f/5fe/ee5f5d1a75229/torch-2.3.0-cp310-cp310-linux_aarch64.whl#sha256=5feee5f5d1a75229eb5290c6fcdc534658dd8b99e55e4a49e8f7c509c313d52d \
    # torchvision
    https://pypi.jetson-ai-lab.dev/jp6/cu124/+f/988/cb71323efff87/torchvision-0.18.0a0+6043bc2-cp310-cp310-linux_aarch64.whl#sha256=988cb71323efff87bcf503c9c4e94a8e19a351c96146d0806f194f48da52aaa2

# tensorrt
RUN sudo apt-get update &&\
    sudo apt-get install -y \
        python3-libnvinfer* &&\
    python3 -m pip install \
        onnx \
        onnx-graphsurgeon \
        pycuda      
