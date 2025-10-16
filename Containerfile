# Warewulf Node Image - Rocky Linux 9

FROM docker.io/rockylinux/rockylinux:9

# Update system and install essential packages for HPC cluster nodes
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
    && dnf clean all

# Remove SELinux policy to reduce image size
# Can be added back if needed for specific deployments
RUN dnf remove -y selinux-policy \
    && dnf clean all

# Set write permissions on root (workaround for OpenHPC compatibility)
RUN chmod u+w /

# Copy Warewulf-specific configuration files
COPY excludes /etc/warewulf/
COPY container_exit.sh /etc/warewulf/

# Run cleanup script
RUN sh /etc/warewulf/container_exit.sh

# Default command - this image is meant to be imported by Warewulf
CMD [ "/bin/echo", "This image is intended to be used with the Warewulf cluster management system. Import it using: wwctl container import docker://ghcr.io/[your-org]/warewulf-rockylinux:9 rockylinux-9" ]
