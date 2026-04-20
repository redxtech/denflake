{ inputs, self, ... }:

{
  den.aspects.window-manager = {
    nixos =
      { pkgs, ... }:
      {
        imports = [ inputs.niri.nixosModules.niri ];

        programs.niri.enable = true;

        # configure greetd to use niri
        services.greetd.settings.default_session.command =
          "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd niri-session";
      };

    homeManager = {
      # programs.niri.settings = { };
    };
  };

  flake-file.inputs.niri = {
    url = "github:sodiboo/niri-flake";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake-file.nixConfig = {
    extra-substituters = [ "https://niri.cachix.org" ];
    extra-trusted-public-keys = [ "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964=" ];
  };
}
