# Multi-Stage Warewulf Image: OpenMPI from Source

A simple example showing how to layer compiled-from-source HPC software onto a Warewulf-ready node image using a Docker multi-stage build.

This Containerfile builds OpenMPI from source in a throwaway builder stage, then copies the compiled tree into the upstream Warewulf-ready Rocky Linux 9 image.

> **Note:** The build toolchain (gcc, gfortran, autotools, devel headers) only matters during compilation. Multi-stage keeps the runtime image lean by leaving all of that behind. Only the compiled `/opt/openmpi` tree (about 100 MB) ships to nodes.

## Quick Start

1. **Build locally** → produces a runtime image with OpenMPI installed at `/opt/openmpi`
2. **Import to Warewulf** → boot nodes with a working MPI stack out of the box

### Local Testing

```bash
podman build -t warewulf-rockylinux-openmpi:latest .
```

Override the OpenMPI version:

```bash
podman build --build-arg OPENMPI_VERSION=5.0.7 -t warewulf-rockylinux-openmpi:latest .
```

### Import to Warewulf

```bash
wwctl image import docker-daemon://warewulf-rockylinux-openmpi:latest rockylinux9-openmpi
```

Or pull from a registry:

```bash
wwctl image import docker://ghcr.io/yourusername/warewulf-rockylinux-openmpi:latest rockylinux9-openmpi
```

## How It Works

**Stages:**

- Builder: `docker.io/rockylinux/rockylinux:9` (plain Rocky 9, just a toolchain)
- Final: `ghcr.io/warewulf/warewulf-rockylinux:9` (kernel, dracut, networking, wwinit already in place)

**What it does:**

- Compiles OpenMPI in the builder stage with `./configure && make && make install`
- Strips binaries and removes libtool archives to shrink the artifact
- Copies `/opt/openmpi` into the final stage
- Installs runtime libraries (`libgfortran`, `libgomp`, `openssh-clients`)
- Drops a `/etc/profile.d/openmpi.sh` script to set `PATH`, `LD_LIBRARY_PATH`, and `MANPATH`

`--enable-orterun-prefix-by-default` is passed to configure so `mpirun` propagates the prefix to spawned ranks without needing env vars set on every host.

## Verify on a Node

After booting a node from the imported image:

```bash
which mpirun                # /opt/openmpi/bin/mpirun
mpirun --version            # OpenMPI version banner
mpicc --showme              # gcc invocation OpenMPI wraps
```

## Customization

**Bump OpenMPI version:** `--build-arg OPENMPI_VERSION=5.0.7` at build time, or edit the default in the Containerfile.

**Add UCX transport:** Add `ucx-devel` to the builder `dnf install`, pass `--with-ucx` to configure, and add `ucx` to the runtime `dnf install`.

**Add libfabric (OFI):** Add `libfabric-devel` to the builder, pass `--with-libfabric`, and add `libfabric` to runtime.

**Add SLURM PMI:** Pass `--with-slurm` and `--with-pmix=external` (requires `pmix-devel` in builder, `pmix` at runtime).

**Full Fortran bindings:** Replace `--enable-mpi-fortran=usempi` with `--enable-mpi-fortran=all`.

If you add network-fabric flags, remember to mirror the runtime libraries (`ucx`, `libfabric`, `pmix`) into the final stage's `dnf install` so the linked binaries can find them at runtime.

## Pattern Reuse

This same pattern works for any compile-from-source HPC software: HPL, HPCG, OpenBLAS, FFTW, or your own application binaries. Build it in the first stage, copy `/opt/<thing>` into the final stage, drop a profile.d script for the environment.
