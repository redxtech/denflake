{ inputs, ... }:

{
  den.aspects.spotify = {
    homeManager =
      { config, inputs', ... }:
      {
        imports = [ inputs.spicetify-nix.homeManagerModules.spicetify ];

        programs.spicetify =
          let
            spicePkgs = inputs'.spicetify-nix.legacyPackages;
          in
          {
            enable = true;
            wayland = true;

            enabledExtensions = with spicePkgs.extensions; [
              bookmark
              keyboardShortcut
              shuffle

              # community extensions
              beautifulLyrics
              betterGenres
              coverAmbience
              fullAlbumDate
              fullAppDisplayMod
              goToSong
              groupSession
              hidePodcasts
              # lastfm # TODO: re-enable when resolved https://github.com/Gerg-L/spicetify-nix/issues/356
              # oldSidebar
              playingSource
              playlistIcons
              playNext
              powerBar
              seekSong
              sessionStats
              showQueueDuration
              skipStats
              songStats
            ];

            enabledCustomApps = with spicePkgs.apps; [
              lyricsPlus
              ncsVisualizer
              newReleases
            ];
          };
      };
  };

  flake-file.inputs.spicetify-nix = {
    url = "github:Gerg-L/spicetify-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
}
