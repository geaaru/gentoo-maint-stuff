FROM scratch

LABEL maintainer="geaaru <geaaru@sabayonlinux.org>"

ARG TARBALL=local
ENV TARBALL ${TARBALL}
ADD ${TARBALL} /

ADD ./gentoo-stuff/ /gentoo-stuff
RUN chmod a+x /gentoo-stuff/stage3.sh

# Add latest portage
ADD ./portage-latest.tar.xz /usr

# Set locales to en_US.UTF-8
ENV LC_ALL=en_US.utf8
ENV TERM=linux

# Set GENTOO_SKIP_SYNC VARIABLE
# See bug: https://github.com/moby/moby/issues/34494
# For now use default value from commons.sh
ARG GENTOO_SKIP_SYNC=0
ENV GENTOO_SKIP_SYNC ${GENTOO_SKIP_SYNC}

# Set profile
ARG GENTOO_PROFILE_NAME=/systemd
ENV GENTOO_PROFILE_NAME ${GENTOO_PROFILE_NAME}

# Set profile version
ARG GENTOO_PROFILE_VERSION=17.0
ENV GENTOO_PROFILE_VERSION ${GENTOO_PROFILE_VERSION}

# Set arch
ARG GENTOO_ARCH=amd64
ENV GENTOO_ARCH ${GENTOO_ARCH}

ARG CACHEBUST=1
RUN /gentoo-stuff/stage3.sh init && \
      /gentoo-stuff/stage3.sh rebuild && \
      rm -rf /gentoo-stuff /usr/portage/

CMD ["/bin/bash"]
