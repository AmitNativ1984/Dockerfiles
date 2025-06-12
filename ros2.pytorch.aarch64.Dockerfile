################################
# BASE IMAGE
################################

ARG BASE_IMAGE
FROM $BASE_IMAGE as base

ENV SHELL /bin/bash
SHELL [ "/bin/bash", "-c" ]

ENV DEBIAN_FRONTEND=noninteractive

# # install common tools
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
#     libglvnd0 \
#     libgl1 \
#     libglx0 \
#     libegl1 \
#     libxext6 \
#     libx11-6 \
#     libopenmpi-dev \
#     libopenblas-base \
#     libomp-dev \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install --no-dependencies pycuda==2024.1.2

# #################################
# ### INSTALL ROS 2 ###############
# #################################
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

RUN sudo apt update \
    && export ROS_APT_SOURCE_VERSION=$(curl -s https://api.github.com/repos/ros-infrastructure/ros-apt-source/releases/latest | grep -F "tag_name" | awk -F\" '{print $4}') \
    && curl -L -o /tmp/ros2-apt-source.deb "https://github.com/ros-infrastructure/ros-apt-source/releases/download/${ROS_APT_SOURCE_VERSION}/ros2-apt-source_${ROS_APT_SOURCE_VERSION}.$(. /etc/os-release && echo $UBUNTU_CODENAME)_all.deb" \
    && sudo apt install /tmp/ros2-apt-source.deb \
    && sudo apt-get update \
    && sudo apt-get install -y \
        ros-$ROS_DISTRO-ros-base \
    && rm -rf /var/lib/apt/lists/* 
