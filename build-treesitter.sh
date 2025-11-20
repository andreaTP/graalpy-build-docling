#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

GRAALPY_BIN=${SCRIPT_DIR}/graalpy-25.0.1-linux-amd64/bin/graalpy
if [[ ! -x "$GRAALPY_BIN" ]]; then
  echo "error: GraalPy not found at $GRAALPY_BIN" >&2
  echo "Set GRAALPY_BIN to an executable GraalPy binary and retry." >&2
  exit 1
fi

npm install -g tree-sitter-cli

declare -A GRAMMARS=(
  [tree-sitter-c]=v0.23.6
  [tree-sitter-java]=v0.23.5
  [tree-sitter-javascript]=v0.23.1
  [tree-sitter-python]=v0.23.2
  [tree-sitter-typescript]=v0.23.2
)

echo "==> Cloning grammars"
for repo in "${!GRAMMARS[@]}"; do
  version="${GRAMMARS[$repo]}"

  if [[ ! -d "$repo" ]]; then
    git clone "https://github.com/tree-sitter/$repo" "$repo"
  fi

  pushd "$repo" >/dev/null
  git fetch --tags
  git checkout "$version"

  if [[ "$repo" == "tree-sitter-typescript" ]]; then
    echo "==> Installing npm dependencies for $repo"
    npm install
    for subdir in typescript tsx; do
      echo "==> Generating C code for $repo/$subdir"
      pushd "$subdir" >/dev/null
      tree-sitter generate
      popd >/dev/null
    done
  else
    echo "==> Generating C code for $repo"
    tree-sitter generate
  fi

  echo "==> Building wheel for $repo with GraalPy"
  "$GRAALPY_BIN" -m pip wheel . \
    --no-deps \
    --no-binary=:all:

  popd >/dev/null
done
