#!/bin/bash
set -euxo pipefail

# Enable swap to help with OOM issues
echo "Enabling swap space..."
if [ -f /swapfile ]; then
    swapon /swapfile || true
    echo "Swap enabled:"
    swapon --show
    free -h
fi

# Set working directory
cd /workspace

# Find graalpy binary
GRAALPY_BIN=$(find . -name "graalpy" -type f -executable | head -n 1)
if [ -z "$GRAALPY_BIN" ]; then
    echo "Error: graalpy binary not found"
    exit 1
fi

# Reduce parallelism to lower memory usage
# Using fewer jobs to prevent OOM
export NINJA_NUM_JOBS=2
export MESON_NUM_JOBS=2
export MAKEFLAGS="-j2"
export MESONPY_BUILD_PARALLEL=2
export NPY_NUM_BUILD_JOBS=2

export CMAKE_BUILD_PARALLEL_LEVEL=2

# Additional memory-saving flags
# export CFLAGS="-O2"
# export CXXFLAGS="-O2"

# Ensure pip is available
echo "Setting up pip..."
${GRAALPY_BIN} -I -m ensurepip || true
${GRAALPY_BIN} -m pip install --upgrade pip setuptools wheel

# Create wheels directory if it doesn't exist
mkdir -p /workspace/wheels

# Build the wheel
echo "Building docling wheel (this may take a while and use significant resources)..."
${GRAALPY_BIN} -m pip wheel --no-cache-dir --verbose -w /workspace/wheels docling==2.58.0

echo "Build complete! Wheel files should be in /workspace/wheels directory."
ls -lh /workspace/wheels/

