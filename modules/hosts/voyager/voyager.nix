{
  inputs,
  self,
  den,
  ...
}:

{
  den.hosts.x86_64-linux.voyager.users.gabe = { };

  den.aspects.voyager = {
    includes = [
      den.aspects.workstation
      den.aspects.gpu
    ];

    nixos = {
      imports = [ inputs.nixos-hardware.nixosModules.framework-16-7040-amd ];

      hardware.facter.reportPath = ./facter.json;

      system.stateVersion = "24.05";
    };

  };

  flake-file.inputs = {
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:nixos/nixos-hardware";
  };
}
