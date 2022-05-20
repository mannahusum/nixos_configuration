#!/usr/bin/env bash
declare -r ISO_URL="https://channels.nixos.org/nixos-21.11/latest-nixos-minimal-x86_64-linux.iso"
declare packer_cache

pushd "$(dirname ${BASH_SOURCE[0]})"

if [ ! -z "${PACKER_CACHE_DIR}" ] && [ -e "${PACKER_CACHE_DIR}" ]; then
  packer_cache="${PACKER_CACHE_DIR}"
elif [ -d "${HOME}/.cache/packer" ]; then
  packer_cache="${HOME}/.cache/packer"
else
  mkdir packer_cache
  packer_cache="./packer_cache"
fi

[ -d httpd ] || mkdir httpd
[ -f httpd/sshkey.pub ] || ssh-keygen -N '' -f httpd/sshkey -q
[ -f httpd/sshkey ] && mv http/sshkey .
[ -f OVMF_VARS.fd ] || cp /run/libvirt/nix-ovmf/OVMF_VARS.fd .
chmod u+rw OVMF_VARS.fd

CHECKSUM=$(curl -s -L ${ISO_URL}.sha256 | cut -d' '  -f1)
PACKER_CACHE_DIR="${packer_cache}" packer build \
  -var "iso_url=${ISO_URL}" \
  -var "iso_checksum=${CHECKSUM}" \
  -on-error=ask \
  nixos-x86_64.pkr.hcl

popd
