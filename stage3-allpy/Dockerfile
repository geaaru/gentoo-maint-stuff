ARG USER=geaaru

# Set arch
ARG TARGET_ARCH=amd64

FROM ${USER}/gentoo-stage3-systemd-${TARGET_ARCH}

LABEL maintainer="geaaru <geaaru@sabayonlinux.org>"

ADD ./gentoo-stuff/ /gentoo-stuff
RUN chmod a+x /gentoo-stuff/stage3_allpy.sh

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

ARG CACHEBUST=1
RUN /gentoo-stuff/stage3_allpy.sh init && \
      /gentoo-stuff/stage3_allpy.sh build && \
      rm -rf /gentoo-stuff /usr/portage/

CMD ["/bin/bash"]
