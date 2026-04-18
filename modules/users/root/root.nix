# aspect for the user "root"

{ den, ... }:

{
  den.aspects.root.nixos =
    { config, ... }:
    {
      users.mutableUsers = false;
      users.users.root.hashedPasswordFile = config.sops.secrets.root-pw.path;
      sops.secrets.root-pw.neededForUsers = true;
    };
}
