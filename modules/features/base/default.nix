{ den, ... }:

{
  den.aspects.base.includes = [
    den.aspects.ssh
    den.aspects.tailscale
  ];
}
