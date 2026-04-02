{ inputs, self, ... }:

{
  den.aspects.bar = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [
          inputs.noctalia.packages.${stdenv.hostPlatform.system}.default
          gpu-screen-recorder # for screen recorder plugin
        ];

        # to make noctalia’s wifi, bluetooth, power-profile, and battery features available
        networking.networkmanager.enable = true;
        hardware.bluetooth.enable = true;
        services.power-profiles-daemon.enable = true;
        services.upower.enable = true;

        # TODO: enable gnome evolution data server for calendar support
      };

    homeManager =
      { pkgs, ... }:
      {
        imports = [ inputs.noctalia.homeModules.default ];

        programs.noctalia-shell.enable = true;
        # programs.niri.settings.spawn-at-startup = [ { command = [ "noctalia-shell" ]; } ];
      };
  };

  flake-file.inputs.noctalia = {
    url = "github:noctalia-dev/noctalia-shell";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake-file.nixConfig = {
    extra-substituters = [ "https://noctalia.cachix.org" ];
    extra-trusted-public-keys = [
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    ];
  };
}
