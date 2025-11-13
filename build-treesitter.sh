#!/usr/bin/env bash
set -euxo pipefail

git clone https://github.com/tree-sitter/py-tree-sitter.git tree-sitter
cd tree-sitter
# Pick a stable release (0.23.1 for example)
git checkout v0.23.1

# Init and update the submodule (this contains the actual C library)
git submodule update --init --recursive

# Build and wheel the Python runtime
graalpy -m pip wheel --verbose . -w ../wheels

# This submodule is your canonical Tree-sitter source
export TREE_SITTER_ROOT="$PWD/tree_sitter"
cd ..

# ------------------------------------------------------------------
# 3️⃣ Grammar repos and versions
# ------------------------------------------------------------------
declare -A GRAMMARS=(
  [tree-sitter-c]=v0.23.6
  [tree-sitter-java]=v0.23.1
  [tree-sitter-javascript]=v0.23.1
  [tree-sitter-python]=v0.23.2
  [tree-sitter-typescript]=v0.23.0
)

mkdir -p wheels

# ------------------------------------------------------------------
# 4️⃣ Build each grammar wheel against the same Tree-sitter headers
# ------------------------------------------------------------------
for repo in "${!GRAMMARS[@]}"; do
  ver="${GRAMMARS[$repo]}"
  echo "🧱 Building $repo ($ver)"
  rm -rf "$repo"
  git clone "https://github.com/tree-sitter/$repo.git"
  cd "$repo"
  git checkout "$ver"

  # Ensure parser.h is present for grammars
  mkdir -p src/tree_sitter
  cp "$TREE_SITTER_ROOT/lib/include/tree_sitter/parser.h" src/tree_sitter/

  export CFLAGS="-I$TREE_SITTER_ROOT/lib/include -Isrc"
  export LDFLAGS="-L$TREE_SITTER_ROOT/lib"

  graalpy-25.0.1-linux-amd64/bin/graalpy -m pip wheel --verbose . -w ../wheels

  cd ..
done

ls -lh wheels/
