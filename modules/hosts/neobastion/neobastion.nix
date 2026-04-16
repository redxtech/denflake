{
  inputs,
  self,
  den,
  ...
}:

{
  den.hosts.x86_64-linux.neobastion.users.gabe = { };

  den.aspects.neobastion = {
    includes = [
      den.aspects.base
      den.aspects.display-manager
      den.aspects.window-manager
    ];

    nixos =
      { pkgs, ... }:
      {
        # environment.systemPackages = [ pkgs.hello ];

        # fix home-manager not working on temp VMs
        # https://github.com/nix-community/home-manager/issues/6364#issuecomment-2965010115
        home-manager.useUserPackages = true;
      };

    # host provides default home environment for its users
    provides.to-users.homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.vim ];
      };
  };
}
