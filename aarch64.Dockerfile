ARG ROS_DISTRO=eloquent
ARG GITLAB_USERNAME=ros2cuisine
ARG TARGET_ARCH=arm64v8
ARG FUNCTION_NAME=bundler
ARG FLAVOR=ubuntu
ARG FLAVOR_VERSION=bionic

FROM alpine AS qemu

#QEMU Download
ENV QEMU_URL https://github.com/balena-io/qemu/releases/download/v3.0.0%2Bresin/qemu-3.0.0+resin-aarch64.tar.gz

RUN apk add curl && curl -L ${QEMU_URL} | tar zxvf - -C . --strip-components 1

FROM ${TARGET_ARCH}/${FLAVOR}:${FLAVOR_VERSION}

COPY --from=qemu qemu-aarch64-static /usr/bin

ARG VCS_REF
ENV DEBIAN_FRONTEND noninteractive

RUN apt update \
    && apt upgrade -y \
    # Install barebones
    #&& apt install -y -q \
    #    python3-numpy \
    && rm -rf /var/lib/apt/lists/* \
    # Create Working directory for builds
    && mkdir -p /cuisine/workspaces

# Choose the directory for builds
WORKDIR /cuisine/workspaces

# Finishing the image
ENTRYPOINT ["/opt/ros/$ROS_DISTRO/ros_entrypoint.sh"]
CMD ["bash"]

LABEL org.label-schema.name="${GITLAB_USERNAME}/${FUNCTION_NAME}:${ROS_DISTRO}-${TARGET_ARCH}-${VCS_REF}" \
      org.label-schema.description="The Minimal build image for cuisine Docker images" \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-url="https://hub.docker.com/ros2cuisine/builder" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.schema-version="1.0.0-rc1" \
      org.label-schema.maintainer="cuisine-dev@ichbestimmtnicht.de" \
      org.label-schema.url="https://github.com/ros2cuisine/cuisine/" \
      org.label-schema.vendor="ichbestimmtnicht" \
      org.label-schema.version=$BUILD_VERSION \
      org.label-schema.docker.cmd="docker run -d ros2cuisine/builder"
