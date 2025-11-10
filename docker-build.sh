#!/bin/bash
set -euxo pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

(
    cd ${SCRIPT_DIR}
    
    echo "Building Docker image..."
    DOCKER_BUILDKIT=1 docker build -t docling-wheel-builder .
    
    echo "Running container with resource limits (8 CPUs, 32GB RAM)..."
    docker run --rm \
        --memory=32g \
        --memory-swap=40g \
        --cpus=8 \
        --memory-reservation=16g \
        -v "${SCRIPT_DIR}/wheels:/workspace/wheels" \
        docling-wheel-builder
)


