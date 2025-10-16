#!/bin/sh
#
# Warewulf Container Cleanup Script
# This script runs at the end of the container build to clean up
# temporary files and machine-specific identifiers

echo "Cleaning up container image..."

# Set locale to avoid issues with special characters
export LANG=C LC_CTYPE=C

# Enable command echoing for transparency
set -x

# Clean all package manager caches to reduce image size
dnf clean all

# Remove machine-specific identifiers
# These need to be unique per node and will be regenerated on boot
rm -f /var/lib/dbus/machine-id
truncate -s0 /etc/machine-id

echo "Container cleanup complete"
