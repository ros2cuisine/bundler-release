# The Bundle image as source for other images

## Important Note for Devs: Don't use any apt-get upgrade or other upgrade commands after this point. Head to the [issue](https://gitlab.com/ros2cuisine/bundler/issues) section to have a look whats holding the build back. Tip: Try to use a different [tag](https://hub.docker.com/repository/docker/ros2cuisine/bundler/tags)

### Instructions

#### Pull the latest image

```bash
docker pull ros2cuisine/bundler:eloquent-latest
```

#### Example Dockerfile instructions for bundling

```Dockerfile
# Building the image


FROM openfaas/classic-watchdog:0.18.6 as watchdog

ARG GITLAB_USERNAME=ros2cuisine
ARG TARGET_ARCH=amd64
ARG ROS_DISTRO=eloquent
ARG TAG=eloquent-latest

# Build instructions
FROM ${GITLAB_USERNAME}/builder:${ROS_DISTRO}-${TARGET_ARCH}-${TAG} as builder

# Have a look at https://gitlab.com/ros2cuisine/builder to learn moore about building instructions

# End of builder image

# Start at the bundler image
FROM ${GITLAB_USERNAME}/bundler:${ROS_DISTRO}-${TARGET_ARCH}-${TAG} as bundle

# Copy watchdog in
COPY --from=watchdog /fwatchdog /usr/bin/fwatchdog

# Copy the bundle
COPY --from=builder /cuisine/workspaces/bundle/output.tar output/

RUN apt update \
    # Add Bash for debugging purposes 
    && apt install -y -q \
        bash \
        # Now your are able to start the container with -i terminal flag
    # Change into the dir with output.tar
    && cd /cuisine/workspaces/output/ \
    # unfold tar
    && tar -xf output.tar \
    # unfold child tar.gz's into the root folder /
    && tar -xf workspace.tar.gz -C / \
    && tar -xf dependencies.tar.gz -C / \
    && tar -xf metadata.tar.gz -C / \
    # remove the output folder
    && rm -rf /cuisine/workspaces/output

# Insert entrypoint
COPY --from=builder /cuisine/workspaces/ros_entrypoint.sh .

# Set to true to see request in function logs
ENV write_debug="false"

# Enable healthcheck
HEALTHCHECK --interval=3s CMD [ -e /tmp/.lock ] || exit 1

# Add watchdog as entrypoint
ENTRYPOINT [ "fwatchdog" ]

# Use bash as shell
CMD ["/bin/bash"]
```
