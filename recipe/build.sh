#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# https://github.com/jaredramirez/tree-sitter-rescript/pull/2
sed -i'' -e s/65609807c628477f3b94052e7ef895885ac51c3c/467dcf99f68c47823d7b378779a6b282d7ef9782/g languages.toml

cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml

HELIX_LIBEXEC="$PREFIX"/libexec/helix

# endian.h on the conda-forge sysroot is old, need to define _BSD_SOURCE
export CFLAGS="-D_BSD_SOURCE"

# build statically linked binary with Rust
RUSTFLAGS="-C link-args=-Wl,-headerpad_max_install_names" cargo install --profile opt --locked --no-track --root "$HELIX_LIBEXEC" --path helix-term

# move executable to $HELIX_LIBEXEC
mv "$HELIX_LIBEXEC"/bin/hx "$HELIX_LIBEXEC"
rmdir "$HELIX_LIBEXEC"/bin

# link the executable to $PREFIX/bin
mkdir -p "$PREFIX"/bin
ln -s "$HELIX_LIBEXEC"/hx "$PREFIX"/bin/hx

# remove extra build files
rm -rf runtime/grammars/sources
rm -rf runtime/grammars/*.dSYM

# copy runtime files
cp -r runtime "$HELIX_LIBEXEC"
