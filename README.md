# The Bundle image that is the source for user images

## Instructions

### Pull the latest image

```bash
docker pull ros2cuisine/bundler:eloquent-amd64-latest
```

### Example Dockerfile instructions for bundling

```Dockerfile
# Building the image


FROM openfaas/classic-watchdog:0.18.6 as watchdog

ARG GITLAB_USERNAME=ros2cuisine
ARG TARGET_ARCH=md64
ARG ROS_DISTRO=eloquent
ARG TAG=latest

FROM ${GITLAB_USERNAME}/builder:${ROS_DISTRO}-${TARGET_ARCH}-${TAG} as builder
# Build instructions

# Have a look at https://gitlab.com/ros2cuisine/builder to learn moore about building instructions

# End of builder image
# Start at the bundler image
FROM ${GITLAB_USERNAME}/bundler:${ROS_DISTRO}-${TARGET_ARCH}-${TAG} as bundle

# Copy watchdog in
COPY --from=watchdog /fwatchdog /usr/bin/fwatchdog

# Copy the bundle
COPY --from=builder /cuisine/workspaces/bundle/output.tar output/

RUN apk update \
    # Add Bash for debugging purposes 
    && apk add \
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

# Add your labels
LABEL org.label-schema.name="ros2cuisine/builder:eloquent-x86_64" \
      org.label-schema.description="The Minimal build image for cuisine Docker images cycle" \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-url="https://hub.docker.com/ros2cuisine/builder" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.schema-version="1.0.0-rc1" \
      org.label-schema.maintainer="cuisine-dev@ichbestimmtnicht.de" \
      org.label-schema.url="https://github.com/ros2cuisine/builder-release/" \
      org.label-schema.vendor="ichbestimmtnicht" \
      org.label-schema.version=$BUILD_VERSION \
      org.label-schema.docker.cmd="docker run -d ros2cuisine/builder"
```
