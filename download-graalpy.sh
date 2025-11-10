#!/bin/bash
set -euxo pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

GRAALPY_VERSION=25.0.1
GRAALPY_TAR=graalpy-${GRAALPY_VERSION}-linux-amd64.tar.gz
GRAALPY=https://github.com/oracle/graalpython/releases/download/graal-${GRAALPY_VERSION}/${GRAALPY_TAR}

(
    cd ${SCRIPT_DIR}

    if [ ! -d "graalpy-${GRAALPY_VERSION}-linux-amd64" ]; then
        wget ${GRAALPY}
        tar -xvf ${GRAALPY_TAR}
        rm ${GRAALPY_TAR}
    fi
)


