{ lib, den, ... }:
{
  den.default.nixos.system.stateVersion = "25.11";
  den.default.homeManager.home.stateVersion = "25.11";

  den.default.includes = [
    den.provides.define-user
    den.provides.hostname
    den.provides.inputs'
    den.provides.self'
  ];

  # enable hm by default
  den.schema.user.classes = lib.mkDefault [ "homeManager" ];

  # host<->user provides
  den.ctx.user.includes = [ den._.mutual-provider ];
}
