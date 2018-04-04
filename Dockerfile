# Development Dockerfile for Bio-Formats
# --------------------------------------
# This dockerfile can be used to build
# a distribution which can then be run
# within a number of different Docker images.

# By default, building this dockerfile will use
# the IMAGE argument below for the runtime image.
ARG IMAGE=openjdk:8-jre-alpine

# To install the built distribution into other runtimes
# pass a build argument, e.g.:
#
#   docker build --build-arg IMAGE=openjdk:9 ...
#

# Similarly, the MAVEN_IMAGE argument can be overwritten
# but this is generally not needed.
ARG MAVEN_IMAGE=maven:3.5-jdk-8

#
# Build phase: Use the maven image for building.
#
FROM ${MAVEN_IMAGE} as maven
RUN mkdir -p /src/target
RUN apt-get update && \
    apt-get install -y python-sphinx
RUN useradd -ms /bin/bash bf
COPY . /src
RUN chown -R bf /src
USER bf
WORKDIR /src
RUN git submodule update --init
RUN mvn

#
# Install phase: Copy the built distribution into a
# clean container to minimize size.
#
FROM ${IMAGE}
COPY --from=maven /src/bio-formats-test/target /opt/bio-formats/test
# ENV PATH $PATH:/opt/bio-formats
ENTRYPOINT ["bash"]
