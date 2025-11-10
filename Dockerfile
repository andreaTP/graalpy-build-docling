FROM ubuntu:22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install build dependencies
RUN apt-get update && \
    apt-get install -y \
    wget \
    build-essential \
    clang \
    python3-dev \
    libffi-dev \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    libncurses5-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libxml2-dev \
    libxmlsec1-dev \
    liblzma-dev \
    cmake make ninja-build pkg-config autoconf automake libtool \
    gfortran \
    gcc \
    g++ \
    llvm \
    llvm-dev \
    liblapack-dev \
    libblas-dev \
    libopenblas-dev \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /workspace

# Copy scripts
COPY download-graalpy.sh /workspace/
COPY build-wheel.sh /workspace/

# Make scripts executable
RUN chmod +x /workspace/download-graalpy.sh /workspace/build-wheel.sh

# Download graalpy
RUN /workspace/download-graalpy.sh

# Set up swap space (8GB) to help with OOM issues
# Note: Swap will be enabled at runtime in build-wheel.sh
# RUN fallocate -l 8G /swapfile && \
#     chmod 600 /swapfile && \
#     mkswap /swapfile

# Default command
CMD ["/workspace/build-wheel.sh"]

