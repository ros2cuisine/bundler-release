# Setup variables
ARG BUILD_USER_NAME=arm64v8
ARG BUILD_REPO=ubuntu
ARG BUILD_VERSION=bionic
ARG DOCKERHUB_NAME=ros2cuisine
ARG IMAGE_NAME
ARG VCS_REF

# Setup qemu
FROM alpine AS qemu

#QEMU Download
ENV QEMU_URL https://github.com/balena-io/qemu/releases/download/v3.0.0%2Bresin/qemu-3.0.0+resin-aarch64.tar.gz

RUN apk add curl && curl -L ${QEMU_URL} | tar zxvf - -C . --strip-components 1

ARG BUILD_USER_NAME=arm64v8
ARG BUILD_REPO=ubuntu
ARG BUILD_VERSION=bionic

# Pull the image
FROM ${BUILD_USER_NAME}/${BUILD_REPO}:${BUILD_VERSION} as bundle

COPY --from=qemu qemu-aarch64-static /usr/bin

# Setup environment
ARG ROS_DISTRO=eloquent
ARG SRC_USER_NAME
ARG BUILD_REPO=ubuntu
# dynamic
ENV ROS_DISTRO ${ROS_DISTRO}
# static
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV DEBIAN_FRONTEND noninteractive

# setup timezone
#RUN apt-get update \
    #echo 'Etc/UTC' > /etc/timezone \
    #&& ln -s -f /usr/share/zoneinfo/Etc/UTC /etc/localtime \
    #&& apt-get update \
#    && apt-get install -q -y tzdata \
#    && rm -rf /var/lib/apt/lists/*

# install packages
RUN apt-get update && apt-get install -q -y \
    dirmngr \
    gnupg2 \
    python3-pip \
    tzdata \
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
ADD https://raw.githubusercontent.com/ros2cuisine/bundler-release/master/ros_entrypoint.sh /

# Choose the directory for builds
WORKDIR /workspaces/cuisine

# Finishing the image
ENTRYPOINT ["/ros_entrypoint.sh"]

CMD ["bash"]
