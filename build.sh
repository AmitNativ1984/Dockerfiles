#!/bin/bash

# Parse input arguments
for arg in "$@"
do
    case $arg in
        docker_registry=*)
        local_docker_registry="${arg#*=}"
        shift
        ;;
        *)
        echo "Usage: $0 docker_registry=<local_docker_registry>"
        return 1
        ;;
    esac
done

if [ -z "$local_docker_registry" ]; then
    echo "Usage: $0 docker_registry=<local_docker_registry>"
    return 1
fi

echo "Docker Registry: $local_docker_registry"

# Build for amd64
docker buildx build \
  --platform linux/amd64 \
  --file ros2.pytorch.amd64.Dockerfile \
  --build-arg BASE_IMAGE=nvcr.io/nvidia/cuda:12.2.2-cudnn8-devel-ubuntu22.04 \
  --build-arg ROS_DISTRO=humble \
  -t $local_docker_registry.local:5000/ros2-pytorch:humble-torch2.3.0-amd64 \
  --push \
   .
# Build for arm64
docker buildx build \
  --platform linux/arm64/v8 \
  --file ros2.pytorch.aarch64.Dockerfile \
  --build-arg BASE_IMAGE=nvcr.io/nvidia/cuda:12.6.3-cudnn-devel-ubuntu22.04 \
  --build-arg ROS_DISTRO=humble \
  -t $local_docker_registry.local:5000/ros2-pytorch:humble-torch2.3.0-aarch64 \
  --push .

# merge multi-arch images
docker buildx imagetools create \
  -t $local_docker_registry.local:5000/ros2-pytorch:humble-torch2.3.0 \
  $local_docker_registry.local:5000/ros2-pytorch:humble-torch2.3.0-amd64 \
  $local_docker_registry.local:5000/ros2-pytorch:humble-torch2.3.0-aarch64
