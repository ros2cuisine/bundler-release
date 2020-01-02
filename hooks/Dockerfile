# Setup variables
ARG SRC_NAME=amd64
ARG SRC_REPO=ubuntu
ARG SRC_TAG=bionic
ARG ROS_DISTRO=eloquent

# Build context
FROM scratch as buildcontext

COPY ros_entrypoint.sh .

# Setup variables
ARG SRC_NAME
ARG SRC_REPO
ARG SRC_TAG

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
    && apt-get install -q -y tzdata \
    && rm -rf /var/lib/apt/lists/*

# install packages
RUN apt-get update && apt-get install -q -y \
        dirmngr \
        gnupg2 \
        python3-pip \
        wget \
        curl \
        gnupg2 \
        lsb-release \
    && rm -rf /var/lib/apt/lists/*

# setup keys
RUN curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add - \
    && wget http://packages.osrfoundation.org/gazebo.key \
    && apt-key add gazebo.key \
    && rm -rf gazebo.key \
    && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654 \
    && echo "deb http://packages.ros.org/ros2/ubuntu bionic main" > /etc/apt/sources.list.d/ros2-latest.list 

# install bootstrap tools
RUN apt-get update \
    && apt-get upgrade -y -q \
    && apt-get install --no-install-recommends -y \
        git \
        python3-colcon-common-extensions \
        python3-colcon-mixin \
        python3-rosdep \
        python3-vcstool \
    && rm -rf /var/lib/apt/lists/*

# bootstrap rosdepsudo apt update && sudo apt autoremove --purge -q -y && sudo apt autoclean -y -q
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
COPY --from=buildcontext ros_entrypoint.sh /

# Choose the directory for builds
WORKDIR /workspaces/cuisine

CMD ["bash"]
