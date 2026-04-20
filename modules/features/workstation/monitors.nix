{
  inputs,
  lib,
  den,
  ...
}:

{
  den.aspects.monitors =
    { settings, ... }:
    {
      settings =
        let
          inherit (lib) mkOption mkEnableOption types;
        in
        with types;
        {
          enable = mkEnableOption "Enable monitors";

          primary = mkOption {
            description = "Primary monitor";
            type = nullOr str;
            default = null;
            readOnly = true;
          };

          monitors = mkOption {
            description = "List of all monitors";
            type = listOf str;
            default = [ ];
          };
        };

      nixos = lib.mkIf settings.monitors.enable {
        programs.atop.enable = true;
      };

      homeManager = lib.mkIf settings.monitors.enable {
        programs.autorandr.enable = true;
      };
    };
}
