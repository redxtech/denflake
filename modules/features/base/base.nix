{ den, lib, ... }:

{
  den.aspects.base = {
    includes = [
      den.aspects.cli
      den.aspects.nix-config
      den.aspects.root
      den.aspects.secrets
      den.aspects.ssh
      den.aspects.style
      den.aspects.tailscale
    ];

    settings.hasDisplay = lib.mkEnableOption "Whether the host has a display";

    nixos = {
      services.userborn.enable = true;
    };
  };
}
