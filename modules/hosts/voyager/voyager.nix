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
      # den.aspects.voyager-fs
      den.aspects.workstation
      den.aspects.gpu

      # until no longer on a VM
      den.aspects.vm
    ];

    nixos = {
      imports = [ inputs.nixos-hardware.nixosModules.framework-16-7040-amd ];

      # TODO: re-enable when not testing in a VM
      # hardware.facter.reportPath = ./facter.json;

      system.stateVersion = "24.05";

      gpu.amd = true;

      # fix home-manager not working on temp VMs
      # https://github.com/nix-community/home-manager/issues/6364#issuecomment-2965010115
      # TODO: remove this when not testing in a VM
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "bak";
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
