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

      (den.provides.unfree [
        "steam-unwrapped"
        "unrar"
        "xkcd-font"
      ])
    ];

    settings.hasDisplay = lib.mkEnableOption "Whether the host has a display";

    nixos = {
      services.userborn.enable = true;
    };
  };
}
