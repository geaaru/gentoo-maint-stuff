#!/bin/bash
# Author: Geaaru, geaaru@gmail.com

. $(dirname $(readlink -f $BASH_SOURCE))/commons.sh

UNMASK_KEYWORDS=(
  "=dev-python/pypy-5.10.0 ~amd64"
  "=dev-python/pypy3-5.10.1 ~amd64"

  "=virtual/pypy-5.10.0 ~amd64"
  "=virtual/pypy3-5.10.1 ~amd64"
)

UNMASK_USES=(
  "# Unmask pypy"
  "-python_targets_pypy"
  "# Unmask pypy3"
  "-python_targets_pypy3"
)

PYVERSIONS=( python{2_7,3_5,3_6,3_7} pypy pypy3 )

gentoo_stage3_allpy_init () {

  local keywords="/etc/portage/package.keywords/00-allpy.keywords"
  local usemask="/etc/portage/profile/use.mask"

  gentoo_set_resolvconf || return 1

  gentoo_set_python_targets "${PYVERSIONS[@]}" || return 1

  for ((i = 0 ; i < ${#UNMASK_KEYWORDS[@]} ; i++)) ; do
    echo ${UNMASK_KEYWORDS[${i}]} >> ${keywords}
  done

  mkdir /etc/portage/profile || return 1

  for ((i = 0 ; i < ${#UNMASK_USES[@]} ; i++)) ; do
    echo ${UNMASK_USES[${i}]} >> ${usemask}
  done

  return 0
}

gentoo_stage3_allpy_build () {

  local emerge_opts="-j --newuse --with-bdeps=y"
  emerge ${emerge_opts} @world || return 1

  return 0
}


case $1 in
  init)
    gentoo_stage3_allpy_init
    ;;
  build)
    gentoo_stage3_allpy_build
    ;;
  *)
  echo "Use init|build"
  exit 1
esac

exit $?
