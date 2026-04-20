{ inputs, ... }:

{
  # provide additional options to any systems running build-vm
  den.aspects.vm.nixos.virtualisation.vmVariant.virtualisation = {
    memorySize = 4096;
    cores = 4;

    qemu.options = [
      "-device virtio-vga-gl"
      "-display sdl,gl=on"
    ];
  };

  # enables `nix run .#vm`. it is very useful to have a VM
  # you can edit your config and launch the VM to test stuff
  # instead of having to reboot each time.
  perSystem =
    { pkgs, lib, ... }:
    {
      packages.vm = pkgs.writeShellApplication {
        name = "vm";
        text =
          let
            machine = "voyager";
            host = inputs.self.nixosConfigurations.${machine}.config;
          in
          ''
            ${host.system.build.vm}/bin/run-${host.networking.hostName}-vm "$@"
          '';
      };
    };
}
