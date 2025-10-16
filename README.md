# Warewulf CI/CD Example

A simple example showing how to automatically build and publish Warewulf node images using GitHub Actions.

This pipeline builds a Rocky Linux 9 container image optimized for HPC clusters and publishes it to GitHub Container Registry (ghcr.io).

> **Note:** This example is a simplified version inspired by [warewulf/warewulf-node-images](https://github.com/warewulf/warewulf-node-images), which provides production-ready container images for multiple Linux distributions.

## Quick Start

1. **Push to main branch** → Builds `:main` tag for testing
2. **Create a GitHub release** → Builds versioned tag for production

### Using the Images

```bash
# Import development build
wwctl container import docker://ghcr.io/yourusername/warewulf-rockylinux:main rockylinux9-dev

# Import production release
wwctl container import docker://ghcr.io/yourusername/warewulf-rockylinux:2025.10.0 rockylinux9-2025-10
```

### Local Testing

```bash
podman build -t warewulf-rockylinux:9 .
```

## How It Works

**Triggers:**

- Push to main → `:main` tag (development)
- GitHub release → `:2025.10.0` tag (production)

**What it does:**

- Builds for amd64 (x86_64)
- Publishes to GitHub Container Registry
- Signs images with Cosign

## Creating a Release

1. Go to "Releases" → "Create a new release"
2. Create a tag: `v2025.10.0` (format: `vYYYY.MM.R`)
3. Add release notes
4. Publish

The workflow automatically builds and publishes `:2025.10.0`

## Customization

**Add packages:** Edit `Containerfile` and add to the `dnf install` line

**Exclude files:** Add patterns to the `excludes` file

**Enable `:latest` tag:** Uncomment line 64 in `.github/workflows/build.yml`

**Enable ARM64 support:** Uncomment line 75 in `.github/workflows/build.yml`

## Why Calendar Versioning?

Tags like `:2025.10.0` make it clear when the image was built, which matters for OS package updates and security patches.
