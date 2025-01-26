# ROS-CUDA-PyTorch Docker Images

This repository contains Dockerfiles for creating Docker images that include ROS, CUDA, and PyTorch.

## Setting Up a Local Docker Registry
1. Run the Docker registry container:
    ```sh
    docker run -d -p 5000:5000 --name registry registry:2
    ```

    ## Configuring Docker Daemon

    To configure the Docker daemon to use your local registry, you need to make changes to the `/etc/docker/daemon.json` file.

    1. Open the `/etc/docker/daemon.json` file in a text editor. If the file does not exist, create it.
    2. Add the following configuration to the file:
        ```json
        {
          "insecure-registries" : ["<hostname>.local:5000"]
        }
        ```
    3. Restart the Docker daemon to apply the changes:
        ```sh
        sudo systemctl restart docker
        ```

    You can replace `<hostname>` with the hostname of your machine.
    To find the hostname of your machine, run the following command:
    ```sh
    hostname
    ```        
    This configuration allows Docker to interact with your local registry without requiring SSL.

## Configuring `buildx` for Multi-Architecture Support
In order to build multi-architecture to your local Docker registry, you need to configure `buildx`, and allow it to use the local registry.

1. Create config file at: `/etc/docker/buildkitd.toml` and add the following lines:
    ```toml
    insecure-entitlements = [ "network.host", "security.insecure" ]

    [registry."docker.io"]
        mirrors = ["<hostname>.local:5000"]
        http = true
        insecure = true

    [registry."<hostname>.local:5000"]
        http = true
        insecure = true
    ```    
3. Create a new builder. Allow the builder to access to host network:
    ```sh
    docker buildx create --name mybuilder --config /etc/docker/buildkitd.toml --use --driver-opt network=host --bootstrap
    ```
   

## Building and Pushing Docker Images

The `build.sh` script is used to build and push two Docker images into a unified Docker image with multi-architecture support.

To use the `build.sh` script, follow these steps:

1. Make the script executable:
    ```sh
    chmod +x build.sh
    ```

2. Run the script:
    ```sh
    ./build.sh
    ```

This will build the Docker images and push them to your local Docker registry.

## License

This project is licensed under the MIT License.