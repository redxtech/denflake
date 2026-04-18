{
  inputs,
  self,
  den,
  ...
}:

{
  den.hosts.x86_64-linux.neobastion.users.gabe = { };

  den.aspects.neobastion = {
    includes = [ den.aspects.workstation ];

    nixos =
      { pkgs, ... }:
      {
        # fix home-manager not working on temp VMs
        # https://github.com/nix-community/home-manager/issues/6364#issuecomment-2965010115
        home-manager.useUserPackages = true;
      };
  };
}
