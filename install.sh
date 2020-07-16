#!/bin/sh

set -e
set -u
set +x

# Configuration
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
INSTALL_DEVICE="/dev/disk/by-id/ata-TS512GMTS430S_F417990005"
declare -a MIRROR_DEVICES=( \
  "/dev/disk/by-id/ata-ST2000LM003_HN-M201RAD_S377J9AG900498" \
  "/dev/disk/by-id/ata-ST2000LM015-2E8174_WCC2LAF1"\
)
BOOT_PARTITION_SIZE=3
SWAP_PARTITION_SIZE=64
LIBVIRT_PARTITION_SIZE=512
SYSTEM_POOL_NAME=manna_ssd
STORAGE_POOL_NAME=manna_spin
LIBVIRT_POOL_NAME=libvirt
KEY_BOOT=$(mktemp -p /dev/shm )
KEY_ZFS=$(mktemp -p /dev/shm )
INSTALL_DIR="/mnt/nixos"
NIX_VERSION=20.03
PASSPHRASE_FILE="${DIR}/passphrase.txt"
TRUE=$(which true)
CRYPT_BOOT_DEV=mannassdboot

# Check for nixos dependencies:

[ -d /nix ] || curl https://nixos.org/nix/install | sh

if ! which nix-env; then
  if [ -f $HOME/.nix-profile/etc/profile.d/nix.sh ] ; then
    $HOME/.nix-profile/etc/profile.d/nix.sh
  else
    echo "Unable to find nix environment. Giving up"
  fi
fi

if ! which parted; then
  nix-env -iA nixos.parted
fi

echo
echo "Initializing"
echo

efiMainPartition="${INSTALL_DEVICE}-part2"
bootMainPartition="${INSTALL_DEVICE}-part3"
swapPartition="${INSTALL_DEVICE}-part4"
rootPartition="${INSTALL_DEVICE}-part5"

echo
echo "Creating keys"
echo

dd if=/dev/urandom of=$KEY_BOOT bs=1024 count=4 >/dev/null
dd if=/dev/urandom of=$KEY_ZFS bs=32 count=1 >/dev/null


echo
echo "Cleaning up"
echo

sudo swapoff "${swapPartition}" || ${TRUE}
sudo umount "${INSTALL_DIR}/boot/efi" || ${TRUE}
sudo umount "${INSTALL_DIR}/boot" || ${TRUE}
sudo umount "${INSTALL_DIR}/home" || ${TRUE}
sudo umount "${INSTALL_DIR}" || ${TRUE}

sudo cryptsetup close $CRYPT_BOOT_DEV || ${TRUE}

if [ -e "${bootMainPartition}" ]; then
  sudo dd if=/dev/zero of=${bootMainPartition} bs=2M count=10 >/dev/null
fi

for pool in "${SYSTEM_POOL_NAME}" "${LIBVIRT_POOL_NAME}" "${STORAGE_POOL_NAME}"; do
  sudo zpool destroy "${pool}" || ${TRUE}
done
# sudo -- sgdisk --zap-all ${INSTALL_DEVICE}
for mirror in "${INSTALL_DEVICE}" "${MIRROR_DEVICES[@]}"; do
  sudo sgdisk --zap-all ${mirror}
  sudo dd if=/dev/zero of=${mirror} bs=2M count=10 >/dev/null
done


echo
echo "Partitioning.."
echo

sudo sgdisk \
  -n1:+:+2M -c 1:grub -t 1:ef02 -A 1:set:2 \
  -n2:+:+512M -c 2:efi -t 2:ef00 \
  -n3:+:+${BOOT_PARTITION_SIZE}G -c 3:boot -t 3:8300 \
  -n4:+:+${SWAP_PARTITION_SIZE}G -c 4:swap -t 4:8300 \
  -n5:+:- -c 5:system -t 5:8300 \
  ${INSTALL_DEVICE} >/dev/null

sectors_in_system=$(sudo LANG=C sgdisk -i5 ${INSTALL_DEVICE} | grep -i size | cut -d' ' -f3)

for mirror in "${MIRROR_DEVICES[@]}"; do
  sudo sgdisk \
    -n1:+:+2M -c 1:grub -t 1:ef02 -A 1:set:2 \
    -n2:+:+512M -c 2:efi -t 2:ef00 \
    -n3:+:+${BOOT_PARTITION_SIZE}G -c 3:boot -t 3:8300 \
    -n5:+:+${sectors_in_system} -c 5:system -t 5:8300 \
    -n6:+:- -c 6:storage -t 6:8300 \
    ${mirror} >/dev/null
done

sleep 3

echo
echo "Formatting.."
echo

if [[ "${#MIRROR_DEVICES[@]}" > 0 ]]; then
  system_zpool_devices="mirror ${rootPartition} ${MIRROR_DEVICES[@]/%/-part5}"
else
  system_zpool_devices="${rootPartition}"
fi

sudo zpool create \
  -f \
  -O atime=on \
  -O relatime=on \
  -O acltype=posixacl \
  -O xattr=sa \
  -O aclinherit=passthrough \
  -O dnodesize=auto \
  -O normalization=formD \
  -o ashift=12 \
  -O encryption=on \
  -O keyformat=raw \
  -O "keylocation=file://${KEY_ZFS}" \
  -O mountpoint=none \
  -O compression=on \
  "${SYSTEM_POOL_NAME}" \
  ${system_zpool_devices}

# Reserve some diskspace for copy-on-write if disk is full
sudo zfs create \
  -o refreservation=1G \
  -o mountpoint=none \
  "${SYSTEM_POOL_NAME}/reserved"

make_storage_mounts() {
  pool=$1; shift

  sudo zfs create \
    -o mountpoint=legacy \
    -o canmount=noauto \
    "${pool}/home"


  sudo zfs create \
    -o canmount=off \
    -o mountpoint=none \
    "${pool}/Virtualisation"

  sudo zfs create \
    -o canmount=off \
    -o mountpoint=none \
    "${pool}/Virtualisation/LXD"

  sudo zfs create \
    -o canmount=off \
    -o mountpoint=none \
    "${pool}/Virtualisation/docker"

  sudo zfs create \
    -V "${LIBVIRT_PARTITION_SIZE}GB" \
    -b "$(getconf PAGESIZE)" \
    -o compression=zle \
    -o logbias=throughput \
    -o sync=always \
    -o primarycache=metadata \
    -o secondarycache=none \
    "${pool}/Virtualisation/libvirt"

  sudo zpool create \
    -f \
    -O atime=on \
    -O relatime=on \
    -O acltype=posixacl \
    -O xattr=sa \
    -O aclinherit=passthrough \
    -O dnodesize=auto \
    -O normalization=formD \
    -o ashift=12 \
    -O mountpoint=none \
    -O compression=off \
    "${LIBVIRT_POOL_NAME}" \
    "/dev/zvol/${pool}/Virtualisation/libvirt"
}

if [[ "${#MIRROR_DEVICES[@]}" > 0 ]]; then
  sudo zpool create \
    -f \
    -O atime=on \
    -O relatime=on \
    -O acltype=posixacl \
    -O xattr=sa \
    -O aclinherit=passthrough \
    -O dnodesize=auto \
    -O normalization=formD \
    -o ashift=12 \
    -O encryption=on \
    -O keyformat=raw \
    -O "keylocation=file://${KEY_ZFS}" \
    -O mountpoint=none \
    -O compression=on \
    "${STORAGE_POOL_NAME}" \
    ${MIRROR_DEVICES[@]/%/-part6}

  sudo zfs create \
    -o refreservation=1G \
    -o mountpoint=none \
    "${STORAGE_POOL_NAME}/reserved"

  make_storage_mounts "${STORAGE_POOL_NAME}"
else
  make_storage_mounts "${SYSTEM_POOL_NAME}"
fi

# sudo zfs create \
#   -V "${SWAP_PARTITION_SIZE}GB" \
#   -b "$(getconf PAGESIZE)" \
#   -o compression=zle \
#   -o logbias=throughput \
#   -o sync=always \
#   -o primarycache=metadata \
#   -o secondarycache=none \
#   -o com.sun:auto-snapshot=false \
#   "${SYSTEM_POOL_NAME}/swap"

sudo mkswap -L swap ${swapPartition}

sudo zfs create \
  -o canmount=off \
  -o mountpoint=none \
  "${SYSTEM_POOL_NAME}/NixOS"

sudo zfs create \
  -o mountpoint=legacy \
  -o canmount=noauto \
  "${SYSTEM_POOL_NAME}/NixOS/root"


sudo mkfs.fat -F 32 -n boot "${efiMainPartition}"

sudo cryptsetup luksFormat \
  --batch-mode \
  --type luks1 \
  -c aes-xts-plain64 \
  -s 256 \
  --pbkdf pbkdf2 \
  "${bootMainPartition}" "${KEY_BOOT}"

sudo cryptsetup luksAddKey \
  --batch-mode \
  --key-file "${KEY_BOOT}" \
  --pbkdf pbkdf2 \
  "${bootMainPartition}" \
  "${PASSPHRASE_FILE}"

sudo cryptsetup open \
  --type luks \
  --key-file \
  "${KEY_BOOT}" "${bootMainPartition}" ${CRYPT_BOOT_DEV}

sudo mkfs.ext4 /dev/mapper/${CRYPT_BOOT_DEV}

# echo "Installing.."

sudo mkdir -p "${INSTALL_DIR}"

sudo mount -t zfs "${SYSTEM_POOL_NAME}/NixOS/root" "${INSTALL_DIR}"
sudo mkdir "${INSTALL_DIR}/home"
if [[ "${#MIRROR_DEVICES[@]}" > 0 ]]; then
  sudo mount -t zfs "${STORAGE_POOL_NAME}/home" "${INSTALL_DIR}/home"
else
  sudo mount -t zfs "${SYSTEM_POOL_NAME}/home" "${INSTALL_DIR}/home"
fi
sudo mkdir "${INSTALL_DIR}/boot"
sudo mount /dev/mapper/${CRYPT_BOOT_DEV} "${INSTALL_DIR}/boot"

sudo cp "${KEY_BOOT}" "${INSTALL_DIR}/boot/keyfileBoot.bin"
sudo cp "${KEY_ZFS}" "${INSTALL_DIR}/boot/keyfileZfs.bin"

pushd "${INSTALL_DIR}/boot"
  sudo rm -f "${INSTALL_DIR}/boot/initrd.keys.gz"
  find keyfile*.bin -print0 | sort -z | sudo cpio -o -H newc -R +0:+0 --reproducible --null | gzip -9 | sudo tee "${INSTALL_DIR}/boot/initrd.keys.gz" >/dev/null
  sudo chmod 000 "${INSTALL_DIR}/boot/initrd.keys.gz" "${INSTALL_DIR}/boot/"keyfile*.bin
popd

bootMainPartitionUuid=$(blkid -o value -s UUID ${bootMainPartition})
bootMainPartitionByUuid="/dev/disk/by-uuid/${bootMainPartitionUuid}"
sudo mkdir "${INSTALL_DIR}/boot/efi"
sudo mount "${efiMainPartition}" "${INSTALL_DIR}/boot/efi"

sudo swapoff -a
sudo swapon "${swapPartition}"
sudo -- `which nixos-generate-config` --root "${INSTALL_DIR}"
sudo swapon -a

{
cat <<EOF
  { boot, ... }:

  {
    boot = {
      initrd.luks.devices."${CRYPT_BOOT_DEV}" = {
        # preLVM = true;
        keyFile = "/keyfileBoot.bin";
        allowDiscards = true;
      };
      loader.grub.devices = [ "${INSTALL_DEVICE}" ]; # or "nodev" for efi only
    };
  }
EOF
} | sudo tee "${INSTALL_DIR}/etc/nixos/bootdevice.nix" >/dev/null
for filename in configuration.nix dropbox.nix users.nix virtualization.nix x11.nix xscreensaver.nix passwords.nix printing.nix 79dachboden5.cer; do
  sudo cp "${filename}" "${INSTALL_DIR}/etc/nixos/${filename}"
done

echo "nixos-install"
sudo zfs set keylocation=file:///keyfileZfs.bin "${SYSTEM_POOL_NAME}"
sudo PATH="$PATH" NIX_PATH="$NIX_PATH" $(which nixos-install) --show-trace --no-root-passwd --root "${INSTALL_DIR}"

