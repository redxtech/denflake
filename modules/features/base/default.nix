{ den, ... }:

{
  den.aspects.base.includes = [
    den.aspects.ssh
    den.aspects.tailscale
    den.aspects.secrets

    den.aspects.root
  ];

  den.aspects.base.nixos = {
    services.userborn.enable = true;
  };
}
