# Set environment variables
ARG TARGET_ARCH
ARG FLAVOR
ARG FLAVOR_VERSION
ARG DOCKERHUB_NAME
ARG IMAGE_NAME
ARG VCS_REF

#Setup Qemu
FROM alpine AS qemu

#QEMU Download
ENV QEMU_URL https://github.com/balena-io/qemu/releases/download/v3.0.0%2Bresin/qemu-3.0.0+resin-arm.tar.gz

RUN apk add curl && curl -L ${QEMU_URL} | tar zxvf - -C . --strip-components 1

#pull image
FROM ${TARGET_ARCH}/${FLAVOR}:${FLAVOR_VERSION}

COPY --from=qemu qemu-arm-static /usr/bin

ARG VCS_REF
ENV DEBIAN_FRONTEND noninteractive

RUN apt update \
    && apt upgrade -y \
    # Install barebones
    #&& apt install -y -q \
    #    python3-numpy \
    && rm -rf /var/lib/apt/lists/* \
    # Create Working directory for builds
    && mkdir -p /workspaces/cuisine

# Choose the directory for builds
WORKDIR /workspaces/cuisine

# Finishing the image
ENTRYPOINT ["/opt/ros/eloquent/ros_entrypoint.sh"]
CMD ["bash"]

ARG DOCKERHUB_NAME
ARG DOCKER_REPO
ARG IMAGE_NAME
ARG VCS_REF

LABEL org.label-schema.name="${DOCKERHUB_NAME}/${DOCKER_REPO}:$IMAGE_NAME}-${VCS_REF}" \
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
