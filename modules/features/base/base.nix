{ den, ... }:

{
  den.aspects.base =
    { config, lib, ... }:
    {
      includes = [
        den.aspects.cli
        den.aspects.secrets
        den.aspects.ssh
        den.aspects.tailscale

        den.aspects.root

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
