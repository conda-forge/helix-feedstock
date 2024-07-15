#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# https://github.com/jaredramirez/tree-sitter-rescript/pull/2
sed -i'' -e s/65609807c628477f3b94052e7ef895885ac51c3c/467dcf99f68c47823d7b378779a6b282d7ef9782/g languages.toml

cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml

HELIX_LIBEXEC="$PREFIX"/libexec/helix
export HELIX_RUNTIME="$HELIX_LIBEXEC"/runtime

# build statically linked binary with Rust
cargo install --locked --root "$PREFIX" --path helix-term

# strip debug symbols
"$STRIP" "$PREFIX"/bin/hx

# create custom launcher
mkdir -p "$HELIX_LIBEXEC"
mv "$PREFIX"/bin/hx "$HELIX_LIBEXEC"/hx
echo -e '#!/bin/bash\nHELIX_RUNTIME="'"$HELIX_RUNTIME"'" exec "'"$HELIX_LIBEXEC"'"/hx "$@"' > "$PREFIX"/bin/hx
chmod +x "$PREFIX"/bin/hx

# remove extra build files
rm -rf runtime/grammars/sources
rm -rf runtime/grammars/*.dSYM

# copy runtime files
cp -r runtime "$HELIX_LIBEXEC"
