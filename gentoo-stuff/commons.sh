#!/bin/bash
# Author: Geaaru, geaaru@gmail.com

MAKE_PORTAGE_FILE=${MAKE_PORTAGE_FILE:-/etc/portage/make.conf}
REPOS_CONF_DIR=${REPOS_CONF_DIR:-/etc/portage/repos.conf/}
GENTOO_PROFILE_VERSION="${GENTOO_PROFILE_VERSION:-17.0}"
GENTOO_PROFILE_NAME="${GENTOO_PROFILE_NAME:-/systemd}"
PORTDIR=${PORTDIR:-/usr/portage}
PORTAGE_LATEST_PATH=${PORTAGE_LATEST_PATH:-/portage-latest.tar.xz}
GENTOO_ARCH="${GENTOO_ARCH:-amd64}"

gentoo_build_info () {

  local profile=${1:-default/linux/${GENTOO_ARCH}/${GENTOO_PROFILE_VERSION}${GENTOO_PROFILE_NAME}}

  echo "
GENTOO_PROFILE_VERSION            = ${GENTOO_PROFILE_VERSION}
GENTOO_PROFILE_NAME               = ${GENTOO_PROFILE_NAME}
GENTOO_PROFILE                    = ${profile}
GENTOO_SKIP_SYNC                  = ${GENTOO_SKIP_SYNC}
GENTOO_ARCH                       = ${GENTOO_ARCH}
"
  return 0
}

gentoo_set_best_mirrors () {

  which mirrorselect 2>&1 > /dev/null
  if [ $? -eq 0 ] ; then
    mirrorselect -s3 -b10 -o >> ${MAKE_PORTAGE_FILE} || return 1
  fi

  return 0
}

gentoo_set_default_shell () {
  local shell=${1:-/bin/bash}

  chsh -s ${shell} || return 1

  return 0
}

gentoo_set_resolvconf () {
  local dns="${1:-8.8.8.8}"

  echo "nameserver ${dns}" > /etc/resolv.conf

  return 0
}


gentoo_check_etc_portage () {

  if [[ ! -d /etc/portage/package.keywords ]] ; then
    mkdir -p /etc/portage/package.keywords
  fi

  if [[ ! -d /etc/portage/package.use ]] ; then
    mkdir -p /etc/portage/package.use
  fi

  if [[ ! -d /etc/portage/package.mask ]] ; then
    mkdir -p /etc/portage/package.mask
  fi

  if [[ ! -d /etc/portage/package.unmask ]] ; then
    mkdir -p /etc/portage/package.unmask
  fi

  if [[ ! -d /etc/portage/package.keywords ]] ; then
    mkdir -p /etc/portage/package.keywords
  fi

  return 0
}

gentoo_set_locale_conf () {

  local lang="${1:-en_US.utf8}"

  for f in /etc/env.d/02locale /etc/locale.conf; do
    echo "LANG=${lang}" > "${f}"
    echo "LANGUAGE=${lang}" >> "${f}"
    echo "LC_ALL=${lang}" >> "${f}"
  done

  return 0
}

gentoo_set_locate () {

  echo 'en_US.utf8 UTF-8' > /etc/locale.gen || return 1

  /usr/sbin/locale-gen

  gentoo_load_locate || return 1

  return 0
}

gentoo_load_locate () {

  eselect locale set en_US.utf8 || return 1

  . /etc/profile

  return 0
}

gentoo_set_all_locales () {

  # Configure glibc locale, ship image with all locales enabled
  # or anaconda will crash if the user selects an unsupported one
  echo '
# /etc/locale.gen: list all of the locales you want to have on your system
#
# The format of each line:
# <locale> <charmap>
#
# Where <locale> is a locale located in /usr/share/i18n/locales/ and
# where <charmap> is a charmap located in /usr/share/i18n/charmaps/.
#
# All blank lines and lines starting with # are ignored.
#
# For the default list of supported combinations, see the file:
# /usr/share/i18n/SUPPORTED
#
# Whenever glibc is emerged, the locales listed here will be automatically
# rebuilt for you.  After updating this file, you can simply run `locale-gen`
# yourself instead of re-emerging glibc.
' > /etc/locale.gen
  cat /usr/share/i18n/SUPPORTED >> /etc/locale.gen || return 1

  /usr/sbin/locale-gen || return 1

  return 0
}

gentoo_set_makeopts () {

  local jobs=${1:-7}

  echo "MAKEOPTS=-j${jobs}" >> ${MAKE_PORTAGE_FILE}

  return $?
}

gentoo_set_python_targets () {

  local targets=${1:-python2_7}

  echo "PYTHON_TARGETS=\"${targets}\"" >> ${MAKE_PORTAGE_FILE}

  return $?
}

gentoo_set_python_single_target () {

  local targets=${1:-python3_5}

  echo "PYTHON_SINGLE_TARGET=\"${targets}\"" >> ${MAKE_PORTAGE_FILE}

  return $?
}

gentoo_create_reposfile () {

  local url=${1:-rsync://rsync.europe.gentoo.org/gentoo-portage}
  local f=${2:-gentoo.conf}

  mkdir -p ${REPOS_CONF_DIR} || return 1

  echo "
[DEFAULT]
main-repo = gentoo

[gentoo]
location = /usr/portage
sync-type = rsync
sync-uri = ${url}
" > ${REPOS_CONF_DIR}${f}

  return $?
}

gentoo_install_overlay () {

  local name=$1
  local unofficial=${2:-0}

  # Fetch list
  layman -f || return 1

  echo "Installing overlay ${name}..."

  # Install overlay
  if [ $unofficial -eq 0 ] ; then
    layman -a ${name} || return 1
  else
    echo 'y' | layman -a ${name} ||  return 1
  fi

  return 0
}

gentoo_set_profile () {

  local profile=${1:-default/linux/${GENTOO_ARCH}/${GENTOO_PROFILE_VERSION}${GENTOO_PROFILE_NAME}}

  eselect profile set ${profile}

  return $?
}

gentoo_set_pyver () {

  local v=${1:-python2.7}

  eselect python set ${v}

  return $?
}

gentoo_init_portage () {

  local skip_sync=${GENTOO_SKIP_SYNC:-1}

  if [ ${skip_sync} -eq 0 ] ; then
    emerge --sync || return 1
  fi

  # Wait to a fix about this on gentoo upstream
  echo "Remove openrc from base packages"
  sed -e 's/*sys-apps\/openrc//g' -i  /usr/portage/profiles/base/packages || return 1

  gentoo_build_info

  gentoo_set_profile || return 1

  gentoo_set_pyver || return 1

  return 0
}


# vim: ts=2 sw=2 expandtab
