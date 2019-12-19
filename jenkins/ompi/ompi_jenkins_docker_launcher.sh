#!/bin/bash -eE

if [ "$DEBUG" = "true" ]; then
    set -x
fi

# WORKSPACE_JENKINS_SCRIPTS - root folder for jenkins_scripts repo
if [ -z "${WORKSPACE_JENKINS_SCRIPTS}" ]
then
    echo "ERROR: WORKSPACE_JENKINS_SCRIPTS is not defined"
    exit 1
fi

# WORKSPACE_OMPI - root folder for OpenMPI source files
if [ -z "${WORKSPACE_OMPI}" ]
then
    echo "ERROR: WORKSPACE_OMPI is not defined"
    exit 1
fi

# BUILD_BUILDID is set by AzureCI
if [ -z "${BUILD_BUILDID}" ]
then
    echo "ERROR: BUILD_BUILDID is not defined"
    exit 1
fi

if [ -z "${OMPI_CI_DOCKER_IMAGE_NAME}" ]
then
    echo "ERROR: OMPI_CI_DOCKER_IMAGE_NAME is not defined"
    exit 1
fi

# Check that you are inside a docker container
cat /proc/1/cgroup

docker images
docker ps -a

printenv

# Run OMPI CI scenarios (build and test)
docker run \
    -v /hpc/local:/hpc/local \
    -v /opt:/opt \
    --network=host \
    --uts=host \
    --ipc=host \
    --ulimit stack=67108864 \
    --ulimit memlock=-1 \
    --security-opt seccomp=unconfined \
    --cap-add=SYS_ADMIN \
    --device=/dev/infiniband/ \
    --env WORKSPACE="${WORKSPACE_OMPI}" \
    --env DEBUG="${DEBUG}" \
    --user swx-jenkins \
    "${OMPI_CI_DOCKER_IMAGE_NAME}" \
    "${WORKSPACE_JENKINS_SCRIPTS}/jenkins/ompi/ompi_jenkins.sh"
