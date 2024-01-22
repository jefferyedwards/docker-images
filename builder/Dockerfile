#
# The runtime base image version.
#
ARG VERSION

#
# Use the runtime:ol8.9-1 image as the base image.
#
FROM runtime:${VERSION}

# 
# Set environment variables
#
ENV M2_HOME=/usr/share/maven
ENV PATH=${M2_HOME}/bin:${PATH}

#
# Install Development Tools, Java 11 SDK, Maven and
# other supporting packages.
#
RUN \
  dnf -y group install               \
    --setopt=install_weak_deps=False \
    --setopt=tsflags=nodocs          \
    "Development Tools";             \
  dnf -y install                     \
    --setopt=install_weak_deps=False \
    --setopt=tsflags=nodocs          \
    java-11-openjdk-devel            \
    jq                               \
    maven                            \
    net-tools                        \
    wget;                            \
  dnf clean all;                     \
  dnf autoremove
