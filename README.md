# Gentoo Ebuilds Maintainer Stuff

Ansible scripts for build docker/LXD images with custom Stage3 rootfs and
test new ebuild before push to gentoo upstream.

Currently support creation of this stage3 images:

  * stage3-systemd: directly a copy of stage3 image after an emerge @world
                    rebuild and move to a pure systemd env.

  * stage3-systemd-libressl: a stage3 image with libressl library instead of openssl

  * stage3-openrc: directly a copy of stage3 image with an emerge @world after push latest
                   portage tarball (TODO)


## Build Images

Under ansible directory, for build step stage3-systemd docker image:

```bash
  $# ansible-playbook --tags amd64_gentoo_stage3 build.yml
```

For build stage3-systemd-libressl docker image:

```bash
  $# ansible-playbook --tags amd64_gentoo_stage3_libressl build.yml
```

### Customize Build Process

Current ansible configuration permit build process on localhost but it is possible configure
Ansible to build images to a remote machine.
See Ansible documentation for details.

In particular, under localhost host variable file it is possible customize these options:

| Option   |  Default | Description |
|----------|----------|-------------|
| builder_rootdir  | ..  | Path of the gentoo-maint-stuff project tree.  |
| docker_user  | geaaru  | Name of the user used for create docker images  |
| gentoo_dist_server  | http://distfiles.gentoo.org/  | URL where retrieve portage tarball and gentoo stage3 file.  |
| gentoo_skip_sync | 1 | Execute portage sync before build process (1) or not (0). |
| gentoo_profile_version | 17.0 | Define Gentoo Profile version to use. |
| staging_dir | ./staging | Directory used by sabayon-lxd-imagebuilder for convert docker image, etc. |
| lxd_target_server | local | Target LXD Server where upload images |
| lxd_skip_pull | 1 | Skip pull from docker image on create LXD images (1) or not (0). Normally, is set to 1 when images are created locally. |

## Test Suites

To permit a continuos delivery of the images and verify that all works fine there are different
playbooks to convert docker images of different tecnologies. Currently, it is supported LXD.

For create LXD image/container it is used latest sabayon-lxd-imagebuilder script (from master).

Currently LXD test suites try to check if rootfs works fine if systemd bootstrap is completed correctly.
Mission is create a list of tests to execute.

For test docker image on LXD images (or with same tags for test customized test):
²
```bash
  $# ansible-playbook lxd.yml -K
```

This playbook create also LXD images related to every steps on configured LXD server and require root permission (or sudo password with -K option).


### Create a fresh container from Docker Image

It is possible use playbook to simplify creation of a container with last image produced with this command:

```bash
  $# ansible-playbook lxd.yml -K --tags amd64_gentoo_stage3_libressl --skip-tags skip_del_container -e container_name="my-container"
```

This create a new container with name "my-container" from gentoo_stage3_libressl image.

For list of all tags:

```
  $# ansible-playbook lxd.yml --list-tags
```

## Architectures supported

Currently, it is supported AMD64 arch but soon will be available ARM7 support.


