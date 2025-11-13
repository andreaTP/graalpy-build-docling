#!/usr/bin/env bash
set -euxo pipefail

git clone https://github.com/tree-sitter/tree-sitter.git
cd tree-sitter
git checkout v0.23.0
make -j$(nproc)
export TREE_SITTER_ROOT="$PWD"
cd ..

declare -A GRAMMARS=(
  [tree-sitter-c]=v0.23.6
  [tree-sitter-java]=v0.23.1
  [tree-sitter-javascript]=v0.23.1
  [tree-sitter-python]=v0.23.2
  [tree-sitter-typescript]=v0.23.0
)

mkdir -p wheels
for repo in "${!GRAMMARS[@]}"; do
  ver="${GRAMMARS[$repo]}"
  echo "Building $repo ($ver)"
  rm -rf "$repo"
  git clone "https://github.com/tree-sitter/$repo.git"
  cd "$repo"
  git checkout "$ver"

  # Make sure parser.h is available to this grammar
  mkdir -p src/tree_sitter
  cp "$TREE_SITTER_ROOT/lib/include/tree_sitter/parser.h" src/tree_sitter/

  export CFLAGS="-I$TREE_SITTER_ROOT/lib/include -Isrc"
  export LDFLAGS="-L$TREE_SITTER_ROOT/lib"

  graalpy-25.0.1-linux-amd64/bin/graalpy -m pip wheel --verbose . -w ../wheels

  cd ..
done

ls -lh wheels/
