#
# The runtime base image version.
#
ARG VERSION

#
# Use the Oracle Linux 8.9 image as the base image.
#
FROM oraclelinux:8.9

#
# Set the maintainer label.
#
LABEL maintainer="jeff@edwardsonthe.net"

# 
# Set environment variables
#
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk
ENV PATH=${JAVA_HOME}/bin:${PATH}

#
# Install C++ runtime libraries and Java 11 JRE.
#
RUN \
  dnf -y update;                     \
  dnf -y install                     \
    --setopt=install_weak_deps=False \
    --setopt=tsflags=nodocs          \
    gcc-c++                          \
    java-11-openjdk;                 \
  dnf clean all;                     \
  dnf autoremove
