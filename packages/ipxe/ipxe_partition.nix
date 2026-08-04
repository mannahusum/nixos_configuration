{
  pkgs,
  lib,
  baseName ? "ipxe",
  diskSize ? 33,
  OVMF ? pkgs.OVMF.fd,
  efiFirmware ? OVMF.firmware,
  efiVariables ? OVMF.variables,
  memSize ? 1024,
  format ? "raw",
  ipxe ? pkgs.ipxe,
  name ? "ipxe_partition",
}: let
  format' = format;
in let
  format =
    if format' == "qcow2-compressed"
    then "qcow2"
    else format';

  compress = lib.optionalString (format' == "qcow2-compressed") "-c";

  filename =
    "${baseName}."
    + {
      qcow2 = "qcow2";
      vdi = "vdi";
      vpc = "vhd";
      raw = "img";
    }
    .${
      format
    } or format;

  binPath = lib.makeBinPath (
    with pkgs;
      [
        util-linux
        gptfdisk
      ]
      ++ stdenv.initialPath
  );

  prepareImage = ''
    export PATH=${binPath}

    # Yes, mkfs.ext4 takes different units in different contexts. Fun.
    sectorsToKilobytes() {
      echo $(( ( "$1" * 512 ) / 1024 ))
    }

    sectorsToBytes() {
      echo $(( "$1" * 512  ))
    }

    # Given lines of numbers, adds them together
    sum_lines() {
      local acc=0
      while read -r number; do
        acc=$((acc+number))
      done
      echo "$acc"
    }

    mebibyte=$(( 1024 * 1024 ))

    # Approximative percentage of reserved space in an ext4 fs over 512MiB.
    # 0.05208587646484375
    #  × 1000, integer part: 52
    compute_fudge() {
      echo $(( $1 * 52 / 1000 ))
    }

    round_to_nearest() {
      echo $(( ( $1 / $2 + 1) * $2 ))
    }

    mkdir $out

    diskImage=nixos.raw
    truncate -s "${toString diskSize}M" $diskImage

    sgdisk -n 1:0:0 -t 1:ef00 -c 1:"EFI System Partition" $diskImage
  '';

  moveOrConvertImage = ''
    ${
      if format == "raw"
      then ''
        mv $diskImage $out/${filename}
      ''
      else ''
        ${pkgs.qemu-utils}/bin/qemu-img convert -f raw -O ${format} ${compress} $diskImage $out/${filename}
      ''
    }
    diskImage=$out/${filename}
  '';

  createEFIVars = ''
    efiVars=$out/efi-vars.fd
    cp ${efiVariables} $efiVars
    chmod 0644 $efiVars
  '';

  createHydraBuildProducts = ''
    mkdir -p $out/nix-support
    echo "file ${format}-image $out/${filename}" >> $out/nix-support/hydra-build-products
  '';
in
  pkgs.vmTools.runInLinuxVM (
    pkgs.runCommand name
    {
      preVM = prepareImage + createEFIVars;
      buildInputs =
        [
          ipxe
        ]
        ++ (with pkgs; [
          util-linux
          e2fsprogs
          dosfstools
        ]);
      postVM = moveOrConvertImage + createHydraBuildProducts;
      QEMU_OPTS = lib.concatStringsSep " " (
        ["-drive if=pflash,format=raw,unit=0,readonly=on,file=${efiFirmware}"]
        ++ [
          "-drive if=pflash,format=raw,unit=1,file=$efiVars"
        ]
        ++ lib.optionals (OVMF.systemManagementModeRequired or false) [
          "-machine"
          "q35,smm=on"
          "-global"
          "driver=cfi.pflash01,property=secure,value=on"
        ]
      );
      inherit memSize;
    }
    ''
      export PATH=${binPath}:$PATH

      disk=/dev/vda

      mkfs.vfat -n "ESP" -F 32 "''${disk}1"

      mountpoint=/mnt
      mkdir "''${mountpoint}"
      mount "''${disk}1" "''${mountpoint}"
      mkdir -p "''${mountpoint}/EFI/BOOT"
      cp "${ipxe}/ipxe.efi" "''${mountpoint}/EFI/BOOT/BOOTX64.h"
      umount "''${mountpoint}"
    ''
  )
