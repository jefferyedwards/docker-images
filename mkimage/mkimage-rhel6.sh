#!/bin/bash
##
## Create a base RHEL6 Docker image.
##
set -e

##
##  Path to RHEL6 ISO file
##
RHEL6_ISO="/home/jeff/share/rhel-server-6.10-x86_64-dvd.iso"

##
## Mount the RHEL 6 ISO
##
[[ ! -d /mnt/rhel6 ]] && sudo mkdir /mnt/rhel6
[[ -z "$(mount | fgrep /mnt/rhel6)" ]] && sudo mount -o loop ${RHEL6_ISO} /mnt/rhel6

##
## Create a RHEL 6 base image
##
# sudo ./bin/mkimage-yum.sh \
#   -g "Core"               \
#   -y ./etc/rhel6-yum.conf \
#   jedwards/rhel6-base

##
## Create a RHEL 6 dev image
##
sudo ./bin/mkimage-yum.sh \
  -p "cmake"              \
  -p "curl"               \
  -p "expect"             \
  -p "gzip"               \
  -p "java-1.7.0-openjdk" \
  -p "tar"                \
  -p "wget"               \
  -p "zip"               \
  -g "Core"               \
  -g "Development Tools"  \
  -y ./etc/rhel6-yum.conf \
  jedwards/rhel6-dev

##
## Unmount the RHEL 6 ISO
##
sudo umount /mnt/rhel6

exit 0
