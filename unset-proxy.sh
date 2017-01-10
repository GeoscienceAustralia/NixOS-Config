#!/usr/bin/env bash

set -e

if [ -n "${http_proxy}" ]; then
    unset all_proxy http_proxy https_proxy ftp_proxy rsync_proxy

    sed -i --follow-symlinks -E "s,^(\s*)(networking.proxy.default)(.*$),\\1# \\2\\3," /etc/nixos/configuration.nix

    export NIX_REMOTE=""
    nix-build -A system "<nixpkgs/nixos>"
    nixos-rebuild switch
fi
