{
  inputs,
  den,
  lib,
  ...
}:

{
  den.schema.host =
    { config, ... }:
    {
      options.settings = lib.mkOption {
        description = "Per-aspect settings namespace";
        default = { };
        type =
          let
            aspectsWithSettings = lib.filterAttrs (_: a: a ? settings) den.aspects;

            reshapeSettings = raw: {
              imports = raw.imports or [ ];
              config = raw.config or { };
              options = builtins.removeAttrs raw [
                "imports"
                "config"
              ];
            };
          in
          lib.types.submodule {
            options = lib.mapAttrs (
              name: aspect:
              lib.mkOption {
                # Pass the dynamically reshaped settings into the submodule
                type = lib.types.submodule (reshapeSettings aspect.settings);
                default = { };
                description = "Settings for the ${name} aspect";
              }
            ) aspectsWithSettings;
          };
      };
    };
}
