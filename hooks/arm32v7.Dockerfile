# Setup variables
ARG SRC_NAME
ARG SRC_REPO
ARG SRC_TAG
ARG ROS_DISTRO

# Build context
FROM scratch as buildcontext

COPY ros_entrypoint.sh .

# Setup Qemu
FROM alpine AS qemu

# QEMU Download
ENV QEMU_URL https://github.com/balena-io/qemu/releases/download/v3.0.0%2Bresin/qemu-3.0.0+resin-arm.tar.gz

RUN apk add curl && curl -L ${QEMU_URL} | tar zxvf - -C . --strip-components 1

# Setup variables
ARG SRC_NAME
ARG SRC_REPO
ARG SRC_TAG

# Pull image
FROM ${SRC_NAME}/${SRC_REPO}:${SRC_TAG} as bundle

COPY --from=qemu qemu-arm-static /usr/bin

# Setup environment
ARG ROS_DISTRO
# dynamic
ENV ROS_DISTRO ${ROS_DISTRO}
# static
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV DEBIAN_FRONTEND noninteractive

# Choose the directory for builds
WORKDIR /workspaces/cuisine

# setup timezone
RUN echo 'Etc/UTC' > /etc/timezone && \
    ln -s -f /usr/share/zoneinfo/Etc/UTC /etc/localtime \
    && apt-get update \
    && apt-get install -q -y \
        tzdata \
        dirmngr \
        gnupg2 \
        curl \
        lsb-release \
    && rm -rf /var/lib/apt/lists/* \
    # setup keys
    && curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add - \
    && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654 \
    && sh -c 'echo "deb [arch=$(dpkg --print-architecture)] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/ros2-latest.list' \
    # Create Working directory for builds
    && mkdir -p /workspaces/cuisine

# setup entrypoint
COPY --from=buildcontext ros_entrypoint.sh /

CMD ["bash"]
