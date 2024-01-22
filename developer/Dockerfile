#
# The builder base image version.
#
ARG VERSION

#
# Use the builder:ol8.9-1 image as the base image.
#
FROM builder:${VERSION}

# 
# Set environment variables for display.
#
ENV \
  DISPLAY=':0'         \
  LANG='en_US.UTF-8'   \
  LC_ALL='en_US.UTF-8'

#
# Install necessary packages for X11, Eclipse, and Firefox and other 
# utilities you might need (like wget, net-tools, etc.).
#
RUN \
  dnf -y update;                     \
  dnf -y install                     \
    --setopt=install_weak_deps=False \
    --setopt=tsflags=nodocs          \
    firefox;                         \
  dnf clean all;                     \
  dnf autoremove

# 
# Add supporting files, such entrypoint script, into the image.
#
COPY rootfs/ /

#
# Install the Eclipse IDE.
#
ADD pkgs/eclipse-java-2023-12-R-linux-gtk-x86_64.tar.gz /opt

RUN \
  ln -s /opt/eclipse/eclipse /usr/local/bin/eclipse

# 
# When the container starts, open a terminal.
#
CMD ["/bin/bash"]

# 
# When the container starts, run the entrypoint script.
#
ENTRYPOINT ["/entrypoint.sh"]