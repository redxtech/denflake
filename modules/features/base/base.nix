{ den, ... }:

{
  den.aspects.base = {
    includes = [
      den.aspects.cli
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

    nixos = {
      services.userborn.enable = true;
    };
  };
}
