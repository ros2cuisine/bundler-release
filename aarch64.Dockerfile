# Setup variables

ARG TARGET_ARCH=arm64v8
ARG DOCKERHUB_REPO=ubuntu
ARG FLAVOR_VERSION=bionic
ARG DOCKERHUB_NAME=ros2cuisine
ARG IMAGE_NAME
ARG VCS_REF

# Setup qemu
FROM alpine AS qemu

#QEMU Download
ENV QEMU_URL https://github.com/balena-io/qemu/releases/download/v3.0.0%2Bresin/qemu-3.0.0+resin-aarch64.tar.gz

RUN apk add curl && curl -L ${QEMU_URL} | tar zxvf - -C . --strip-components 1

ARG TARGET_ARCH=arm64v8
ARG DOCKERHUB_REPO=ubuntu
ARG BUILD_VERSION=bionic

# Pull the image
FROM ${TARGET_ARCH}/${DOCKERHUB_REPO}:${BUILD_VERSION} as bundle

COPY --from=qemu qemu-aarch64-static /usr/bin

# setup environment
ARG ROS_DISTRO
ARG TARGET_ARCH
ARG DOCKERHUB_REPO=ros
# dynamic
ENV ROS_DISTRO ${ROS_DISTRO}
# static
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV DEBIAN_FRONTEND noninteractive

# setup timezone
RUN echo 'Etc/UTC' > /etc/timezone && \
    ln -s /usr/share/zoneinfo/Etc/UTC /etc/localtime && \
    apt-get update && apt-get install -q -y tzdata && rm -rf /var/lib/apt/lists/*

# install packages
RUN apt-get update && apt-get install -q -y \
    dirmngr \
    gnupg2 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# setup keys
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

# install bootstrap tools
RUN echo "deb http://packages.ros.org/ros2/ubuntu bionic main" > /etc/apt/sources.list.d/ros2-latest.list \
    && apt-get update \
    && apt-get upgrade -y -q \
    && apt-get install --no-install-recommends -y \
        git \
        python3-colcon-common-extensions \
        python3-colcon-mixin \
        python3-rosdep \
        python3-vcstool \
    && rm -rf /var/lib/apt/lists/*

# bootstrap rosdep
RUN rosdep init \
    && rosdep update

# setup colcon mixin and metadata
RUN colcon mixin add default \
      https://raw.githubusercontent.com/colcon/colcon-mixin-repository/master/index.yaml && \
    colcon mixin update && \
    colcon metadata add default \
      https://raw.githubusercontent.com/colcon/colcon-metadata-repository/master/index.yaml && \
    colcon metadata update

# install python packages
RUN pip3 install -U \
    argcomplete \
    # Create Working directory for builds
    && mkdir -p /workspaces/cuisine

# setup entrypoint
COPY ./ros_entrypoint.sh /

# Choose the directory for builds
WORKDIR /workspaces/cuisine

# Finishing the image
ENTRYPOINT ["/ros_entrypoint.sh"]

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
