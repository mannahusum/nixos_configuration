{
  config,
  pkgs,
  ...
}: {
  networking = {
    hostName = "mannavm"; # Define your hostname.
  };
  virtualisation = {
    diskSize = 8000; # MB
    memorySize = 10240; # MB
    # qemu.options = [
    #   "-virtfs local,path=${mount_host_path},security_model=none,mount_tag=${mount_tag}"
    # ];

    # We don't want to use tmpfs, otherwise the nix store's size will be bounded
    # by a fraction of available RAM.
    writableStoreUseTmpfs = false;

    # Because we want to test GRUB.
    # This may require `system-features = kvm` in your `nix.conf`, and your user
    # to be part of the `kvm` group, otherwise you may get:
    #     Could not access KVM kernel module: Permission denied
    useBootLoader = true;
  };
}
