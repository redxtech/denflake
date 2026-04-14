# aspect for the user "root"

{ den, ... }:

{
  den.aspects.root = {
    includes = [
      den.provides.define-user
      (den.provides.user-shell "fish")
    ];

    nixos =
      { config, ... }:
      {
        users.mutableUsers = false;
        users.users.root.hashedPasswordFile = config.sops.secrets.root-pw.path;

        sops.secrets.root-pw.neededForUsers = true;
      };
  };
}
