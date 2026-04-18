# enables `nix run .#vm`. it is very useful to have a VM
# you can edit your config and launch the VM to test stuff
# instead of having to reboot each time.
{ inputs, den, ... }:
{

  perSystem =
    { pkgs, lib, ... }:
    {
      packages.vm = pkgs.writeShellApplication {
        name = "vm";
        text =
          let
            machine = "voyager";
            host = inputs.self.nixosConfigurations.${machine}.config;
            hasDisplay = true;
            cliArgs = lib.optionalString hasDisplay "-device virtio-vga-gl -display sdl,gl=on";
          in
          ''
            ${host.system.build.vm}/bin/run-${host.networking.hostName}-vm ${cliArgs} "$@"
          '';
      };
    };
}
