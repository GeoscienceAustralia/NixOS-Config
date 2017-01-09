# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box = "ga-base"
  config.ssh.username = "guest"
  config.ssh.password = "change-me"

  config.vm.provision "shell",
      env: {"host_http_proxy" => ENV["http_proxy"]},
      inline: <<-SHELL
#!/usr/bin/env bash

set -e

if [ "${http_proxy}" != "${host_http_proxy}" ]; then
    export http_proxy=${host_http_proxy}
    export https_proxy=${host_http_proxy}
    change_proxy=true
fi

if [ ! -f /etc/nixos/configuration.nix ]; then
    git clone https://github.com/GeoscienceAustralia/NixOS-Machines /etc/nixos
    (cd /etc/nixos && ln -s machines/ga/configuration.nix)
    rebuild=true
fi

if [ -n "${change_proxy}" ]; then
    sed -i -E "s,^(\s*)(networking.proxy.default)(.*$),\\1#\\2\\3\\n\\1\\2 = \\"${http_proxy}\\";," /etc/nixos/machines/ga/configuration.nix 
    export NIX_CURL_FLAGS="-x ${http_proxy}"
    export NIX_REMOTE=""
    nix-build -A system "<nixpkgs/nixos>"
    rebuild=true
fi

if [ -n "${rebuild}" ]; then
    nixos-rebuild switch
fi

SHELL
end
