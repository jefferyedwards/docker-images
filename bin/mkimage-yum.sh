#!/bin/bash
##
## Create a base Docker image.
##
## This script is useful on systems with yum installed (e.g., building
## a CentOS image on CentOS).
##
set -e

usage() {
	cat << EOOPTS
$(basename $0) [OPTIONS] <name>
OPTIONS:
  -p "<packages>"  The list of packages to install in the container.
                   The default is blank. Can use multiple times.
  -g "<groups>"    The groups of packages to install in the container.
                   The default is "Core". Can use multiple times.
  -y <yumconf>     The path to the yum config to install packages from. The
                   default is /etc/yum.conf for Centos/RHEL and /etc/dnf/dnf.conf for Fedora
  -t <tag>         Specify Tag information.
                   default is referred at /etc/{redhat,system}-release
EOOPTS
	exit 1
}

##
## Option defaults
##
yum_config=/etc/yum.conf
if [[ -f "/etc/dnf/dnf.conf" && -n "$(command -v dnf)" ]]; then
	yum_config=/etc/dnf/dnf.conf
	alias yum=dnf
fi

##
## Parse command line options.
##
## Note: For names with spaces, use double quotes (") as install_groups=('Core' '"Compute Node"')
##
install_groups=()
install_packages=()
version=
while getopts ":y:p:g:t:h" opt; do
	case $opt in
		y)
			yum_config=${OPTARG}
			;;
		h)
			usage
			;;
		p)
			install_packages+=("${OPTARG}")
			;;
		g)
			install_groups+=("${OPTARG}")
			;;
		t)
			version="${OPTARG}"
			;;
		\?)
			echo "Invalid option: -${OPTARG}"
			usage
			;;
	esac
done

shift $((OPTIND - 1))
name=$1

[[ -z "${name}" ]] && usage

# yum -c "${yum_config}" grouplist --hidden
# yum -c "${yum_config}" grouplist --ids
# yum -c "${yum_config}" groupinfo Base Core "Development Tools" "Java Platform"
# yum -c "${yum_config}" search curl
# yum -c "${yum_config}" search gzip
# yum -c "${yum_config}" search *kernel*
# yum -c "${yum_config}" search wget
# yum -c "${yum_config}" search tar
# yum -c "${yum_config}" info gzip
# yum -c "${yum_config}" repolist
# exit 1

##
## Default to Core group if not specified otherwise.
##
[[ ${#install_groups[@]} -eq 0 ]] && install_groups=('Core')

# target=/tmp/mkimage
# [[ -d "/tmp/mkimage" ]] && rm -rf /tmp/mkimage/* || mkdir /tmp/mkimage
target=$(mktemp -d --tmpdir $(basename $0).XXXXXX)

set -x

##
##  Generate device files required for the guest OS
##
mkdir -m 755 "${target}"/dev
mknod -m 600 "${target}"/dev/console c 5 1
mknod -m 600 "${target}"/dev/initctl p
mknod -m 666 "${target}"/dev/full c 1 7
mknod -m 666 "${target}"/dev/null c 1 3
mknod -m 666 "${target}"/dev/ptmx c 5 2
mknod -m 666 "${target}"/dev/random c 1 8
mknod -m 666 "${target}"/dev/tty c 5 0
mknod -m 666 "${target}"/dev/tty0 c 4 0
mknod -m 666 "${target}"/dev/urandom c 1 9
mknod -m 666 "${target}"/dev/zero c 1 5

##
## Amazon Linux yum will fail without vars set
##
if [[ -d "/etc/yum/vars" ]]; then
	mkdir -p -m 755 "${target}"/etc/yum
	cp -a /etc/yum/vars "${target}"/etc/yum/
fi

##
## Install group of packages (`-g "<groups>"` option).
##
if [[ -n "${install_groups}" ]]; then
	yum \
		-c "${yum_config}" \
		--installroot="${target}" \
		--releasever=/ \
		--setopt=tsflags=nodocs \
		--setopt=group_package_types=mandatory \
		-y \
		groupinstall \
		"${install_groups[@]}"
fi

##
## Install list of packages (`-p "<packages>"` option).
##
if [[ -n "${install_packages}" ]]; then
	yum \
		-c "${yum_config}" \
		--installroot="${target}" \
		--releasever=/ \
		--setopt=tsflags=nodocs \
		--setopt=group_package_types=mandatory \
		-y \
		install \
		"${install_packages[@]}"
fi

yum \
	-c "${yum_config}" \
	--installroot="${target}" \
	-y \
	clean all

##
## Housekeeping
##
cat > "${target}"/etc/sysconfig/network << EOF
NETWORKING=yes
HOSTNAME=localhost.localdomain
EOF

sed -i 's/^SELINUX=.*/SELINUX=disabled/' "${target}"/etc/selinux/config

sed -i 's/^enabled=.*/enabled=0/' "${target}"/etc/yum/pluginconf.d/subscription-manager.conf

# effectively: febootstrap-minimize --keep-zoneinfo --keep-rpmdb --keep-services "${target}".
# locales
rm -rf "${target}"/usr/{{lib,share}/locale,{lib,lib64}/gconv,bin/localedef,sbin/build-locale-archive}

# docs and man pages
rm -rf "${target}"/usr/share/{man,doc,info,gnome/help}

# cracklib
rm -rf "${target}"/usr/share/cracklib

# i18n
rm -rf "${target}"/usr/share/i18n

# rpm database
rm  -rf "${target}"/var/lib/rpm/*

# yum cache
# rm -rf "${target}"/var/cache/yum
rm -rf "${target}"/var/cache/{dnf,yum}
mkdir -p --mode=0755 "${target}"/var/cache/yum

# yum repos
rm  -rf "${target}"/etc/yum.repos.d/*

# sln
rm -rf "${target}"/sbin/sln

# ldconfig
rm -rf "${target}"/etc/ld.so.cache "${target}"/var/cache/ldconfig
mkdir -p --mode=0755 "${target}"/var/cache/ldconfig

if [[ -z "${version}" ]]; then
	for file in "${target}"/etc/{redhat,system}-release; do
		if [[ -r "${file}" ]]; then
			version="$(sed 's/^[^0-9\]*\([0-9.]\+\).*$/\1/' "${file}")"
			break
		fi
	done
fi

if [[ -z "${version}" ]]; then
	echo >&2 "warning: cannot auto-detect OS version, using '${name}' as tag"
	version=${name}
fi

##
## Create container
## 
# tar --numeric-owner -c -f /tmp/${name}.tar -C "${target}" .
tar --numeric-owner -c -C "${target}" . | docker import - ${name}:${version}

docker run -i -t --rm ${name}:${version} /bin/bash -c 'echo success'

rm -rf "${target}"
