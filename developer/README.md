
## Running the container

```bash
docker run -it --rm \
  -e DISPLAY=${DISPLAY} \
  -e HOME=${HOME} \
  -e UID=$(id -u) \
  -e GID=$(id -g) \
  -e USER=$(id -un) \
  -e GROUP=$(id -gn) \
  -v ${HOME}:${HOME} \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -w ${HOME} \
  developer:ol8.9-1
```

