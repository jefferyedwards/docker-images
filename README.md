# Docker Images
Create a Docker base image for `yum` based distributions.  This project leverages the `mkimage-yum.sh`
script found in the `contrib` directory of the [Moby](https://github.com/moby/moby) project.

## mkimage-yum.sh
`mkimage-yum.sh --help` provides details on script usage:
```bash
OPTIONS:
  -p <packages>    The list of packages to install in the container.
                   The default is blank. Can use multiple times.
  -g <groups>      The groups of packages to install in the container.
                   The default is "Core". Can use multiple times.
  -y <yumconf>     The path to the yum config to install packages from. The
                   default is /etc/yum.conf for Centos/RHEL and /etc/dnf/dnf.conf for Fedora
  -t <tag>         Specify Tag information.
                   default is referred at /etc/{redhat,system}-release
```

## Building an image from an ISO file
1. Mount the ISO file:
```
sudo mkdir /mnt/media
sudo mount -o loop /path/to/iso-file /mnt/media
```
2. Create a `yum.conf` to install packages from the mounted ISO file:
```
[main]
reposdir=file:///mnt/media/
keepcache=0
gpgcheck=1
plugins=1

[media-repo]
name=Media Repo
baseurl=file:///mnt/media/
gpgcheck=1
gpgkey=file:///mnt/media/<RPM-GPG-KEY-file-name>
enabled=1
```
3. Use the `mkimage-yum.sh` script to create the base image:
```
sudo mkimage-yum.sh -y yum.com <your-image-name>
```
4. Unmount the ISO file:
```
sudo umount /mnt/media
```
