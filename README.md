# The Bundle image as source for other images

## Important Note for Devs: Don't use any apt-get upgrade or other upgrade commands after this point. Head to the [issue](https://gitlab.com/ros2cuisine/templates/bundler/issues) section to have a look whats holding the build back. Tip: Try to use a different [tag](https://hub.docker.com/repository/docker/ros2cuisine/bundler/tags)

### Instructions

#### Pull the latest image

```bash
docker pull ros2cuisine/bundler
```

#### Example Dockerfile instructions for bundling

```Dockerfile
# Building the image


FROM openfaas/classic-watchdog:0.18.6 as watchdog

# Build instructions
FROM ros2cuisine/builder as builder

RUN apt update \
    # Source ros
    && . /ros_entrypoint.sh \
    # Build the workspace
    && colcon build \
    # Begin Bundling
    && colcon bundle

# Have a look at https://gitlab.com/ros2cuisine/templates/builder to learn moore about building instructions

# End of builder image

# Start at the bundler image
FROM ros2cuisine/bundler as bundle

# Copy watchdog in
COPY --from=watchdog /fwatchdog /usr/bin/fwatchdog

# Copy the bundle
COPY --from=builder /cuisine/workspaces/bundle/output.tar output/

RUN apt update \
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

Build the image local

```bash
docker build . -t appname:localbuild
```
