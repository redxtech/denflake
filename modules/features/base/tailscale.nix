{ inputs, self, ... }:

{
  den.aspects.tailscale =
    { host, ... }:
    {
      nixos =
        { config, ... }:
        {
          services.tailscale = {
            enable = true;
            authKeyFile = config.sops.secrets.tailscale-init-authkey.path;
          };

          sops.secrets.tailscale-init-authkey = { };
        };
    };
}
