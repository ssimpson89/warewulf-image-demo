# Warewulf Node Image - Rocky Linux 9

FROM docker.io/rockylinux/rockylinux:9

# Warewulf version to install
ARG WAREWULF_VERSION=4.6.4

# Install essential packages, remove SELinux, and install Warewulf dracut module
RUN dnf update -y \
    && dnf install -y --allowerasing \
      coreutils \
      cpio \
      dhclient \
      e2fsprogs \
      ethtool \
      findutils \
      initscripts \
      ipmitool \
      iproute \
      kernel-core \
      kernel-modules \
      net-tools \
      NetworkManager \
      nfs-utils \
      openssh-clients \
      openssh-server \
      pciutils \
      psmisc \
      rsync \
      rsyslog \
      strace \
      wget \
      which \
      words \
    # Remove SELinux policy to reduce image size (can be added back if needed)
    && dnf remove -y selinux-policy \
    # Install Warewulf dracut module for network boot support
    && dnf install -y https://github.com/warewulf/warewulf/releases/download/v${WAREWULF_VERSION}/warewulf-dracut-${WAREWULF_VERSION}-1.el9.noarch.rpm \
    && dnf clean all \
    # Set write permissions on root (workaround for OpenHPC compatibility)
    && chmod u+w /

# Generate initramfs with Warewulf support
RUN dracut --force --no-hostonly --add wwinit --regenerate-all

# Copy Warewulf-specific configuration files
COPY excludes /etc/warewulf/
COPY container_exit.sh /etc/warewulf/

# Run cleanup script
RUN sh /etc/warewulf/container_exit.sh

# Default command - this image is meant to be imported by Warewulf
CMD [ "/bin/echo", "This image is intended to be used with the Warewulf cluster management system. Import it using: wwctl container import docker://ghcr.io/[your-org]/warewulf-rockylinux:9 rockylinux-9" ]
