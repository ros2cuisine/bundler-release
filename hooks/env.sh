# Preset global variables from hub.docker.com
# SOURCE_BRANCH: the name of the branch or the tag that is currently being tested.
# SOURCE_COMMIT: the SHA1 hash of the commit being tested.
# COMMIT_MSG: the message from the commit being tested and built.
# DOCKER_REPO: "test" the name of the Docker repository being built.
# DOCKERFILE_PATH: the dockerfile currently being built.
# DOCKER_TAG: the Docker repository tag being built.
# IMAGE_NAME: the name and tag of the Docker repository being built. (This variable is a combination of DOCKER_REPO:DOCKER_TAG.)

# Hardcoded Variables that are pointless to change
# LABEL_BUILD_DATE="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
# LABEL_VCS_REF="$(git rev-parse --short HEAD)"

# Multi entry variables
# LABEL_ only: Use a double underscore __ for an hyphen -
# LABEL_
LABEL_DESCRIPTION="Description not provided"
# You find 6 moore standard labels like maintainer and vendor within the optional section

# BUILD_ARG_
BUILD_ARGS=true
BUILD_ARG_SRC_REPO="ubuntu"
BUILD_ARG_SRC_TAG="bionic"
BUILD_ARG_ROS_DISTRO="eloquent"

BUILD_HOSTS=false
# BUILD_HOST_

BUILD_CGROUPS=false
# BUILD_CGROUP_

# Optional variables with their defaults
# be aware to order them correctly in case you copy them to the top
# DO NOT DELETE THEM
DEST_ARCHES="amd64 arm32v7 arm64v8"
BUILD_COMPRESS=true
BUILD_ISOLATION=false
BUILD_FORCE_RM=true
BUILD_NO_CACHE=false
BUILD_PULL=true
BUILD_QUIET=false
BUILD_TARGET_STAGE=false

DEST_HUB="index.docker.io"
DEST_USER="ichbestimmtnicht"
DEST_REPO="bundler"
DEST_TAG="${DOCKER_TAG}"

LABEL_DOCKER_CMD="docker pull ros2cuisine/bundler"
LABEL_MAINTAINER="ichbestimmtnicht"
LABEL_NAME="ros2cuisine/bundler"
LABEL_VCS_URL="https://github.com/ros2cuisine/bundler-release"
LABEL_VENDOR="ichbestimmtnicht"
LABEL_SCHEMA_VERSION="1.0.0-rc1"

# Placeholder and testing variables
# DO NOT CHANGE OR DELETE THEM
BUILD_ARCH="amd64"
BUILD_SINGLE_DOCKERFILE=false # PLANNED
BUILD_SQUASH=false # Experimental Features are not enabled
BUILD_PLATFORM=false # Experimental features are not enabled

DEST_OS="linux"
