#!/usr/bin/env bash

set -e

new_proxy=$1

if [ "${http_proxy}" != "${new_proxy}" ]; then
    export http_proxy=${new_proxy}
    export https_proxy=${new_proxy}

    sed -i --follow-symlinks -E "s,^(\s*)(networking.proxy.default)(.*$),\\1# \\2\\3\\n\\1\\2 = \\"${http_proxy}\\";," /etc/nixos/configuration.nix

    export NIX_CURL_FLAGS="-x ${http_proxy}"
    export NIX_REMOTE=""
    nix-build -A system "<nixpkgs/nixos>"
    nixos-rebuild switch
fi
