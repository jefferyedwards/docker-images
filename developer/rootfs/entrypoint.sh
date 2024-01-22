#!/bin/bash

# 
# Default values if not provided
#
DEFAULT_UID=9001
DEFAULT_GID=9001
DEFAULT_USER=devuser
DEFAULT_GROUP=devgroup

# 
# Accept UID, GID, user name, and group name from environment variables
#
UID=${UID:-${DEFAULT_UID}}
GID=${GID:-${DEFAULT_GID}}
USER=${USER:-${DEFAULT_USER}}
GROUP=${GROUP:-${DEFAULT_GROUP}}
HOME=${HOME:-"/home/"${USER}}

# 
# Create the group (if not already existing)
#
if [[ -z $(getent group ${GROUP}) ]]; then
  groupadd -g ${GID} ${GROUP}
fi

# 
# Create the user (if not already existing)
#
if [[ -z $(getent passwd ${USER}) ]]; then
  useradd -l -u ${UID} -g ${GROUP} -m -d ${HOME} ${USER} 2>/dev/null
  # If the user's home directory is expected to be mounted, set directory permissions
  chown ${USER}:${GROUP} ${HOME}
fi

# 
# Execute the passed command as the specified user
#
exec runuser -u ${USER} -- "$@"
