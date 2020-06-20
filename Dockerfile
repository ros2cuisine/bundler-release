# Dummy Dockerfile because hooks aren't working with a custom Filename
# Have a look into the hooks folder to see them per arch
# https://gitlab.com/ros2cuisine/templates/bundler/tree/master/hooks/

# Build context
FROM scratch as buildcontext

# Pull image
FROM ${SRC_NAME}/${SRC_REPO}:${SRC_TAG} as bundle

# Setup build arguments
ARG ROS_DISTRO

# setup environments
ENV ROS_DISTRO ${ROS_DISTRO}

# static
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV DEBIAN_FRONTEND noninteractive

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
    # setup keys
    && curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add - \
    && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654 \
    && sh -c 'echo "deb [arch=$(dpkg --print-architecture)] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/ros2-latest.list' \
    && rm -rf /var/lib/apt/lists/*
