{
  description = "Fixed NixOS osu!";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    (flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; overlays = [ self.overlay ]; };
      in
      {
        packages.osu-lazer = pkgs.osu-lazer;
        defaultPackage = self.packages.${system}.osu-lazer;
      })) // {
      overlay = final: prev: {
        osu-lazer = prev.osu-lazer.overrideAttrs (super: {
          patches = [ ./bypass-tamper-detection.patch ];
          patchFlags = [ "--binary" "-p1" ];
        });
      };
    };
}
