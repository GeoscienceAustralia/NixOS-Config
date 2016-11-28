#!/usr/bin/env bash

# Default nix channel in Travis-CI is nixos-unstable. We will use nix-stable, which is 16.09.
# nix-channel --add https://nixos.org/channels/nixos-16.09 nixos
# nix-channel --update

# nix-collect-garbage -d
# nix-store --optimise

nix-env -iA nixpkgs.awscli

nix-build release.nix -A ova

# if [ "${TRAVIS_PULL_REQUEST}" = "false" ]; then
aws configure set aws_access_key_id "${TRAVIS_AWS_ACCESS_KEY_ID}" --profile geodesy
aws configure set aws_secret_access_key "${TRAVIS_AWS_SECRET_KEY_ID}" --profile geodesy
aws configure set region ap-southeast-2 --profile geodesy
aws configure set output json --profile geodesy
aws --profile geodesy s3 cp result/*.ova s3://geodesy-nixos --acl public-read
# fi
