# osu! NixOS

The `osu-lazer` package available on NixOS does not have any online capabilities due to an unfortunate mistake by very poorly informed developers, and nixpkgs maintainers' disappointing lack of respect for their users.

This overlay provides a fixed copy and will continue to do so until the bug is fixed upstream or I am legally required to stop.


## Usage

### With flakes

Our flake will output both `packages.${system}.osu-lazer`, and an overlay (as `overlay`) which will fix your osu-lazer package.

Examples:

```nix
let
  pkgs = import nixpkgs { inherit system; overlays = [ osu-nixos.overlay ]; };
in {}
```

```nix
{
  environment.systemPackages = [ osu-nixos.packages.${system}.osu-nixos ];
}
```

### Without flakes

We use flake-compat to make this available to users without Nix flake support too, importing our `./default.nix` will yield the same results as you would otherwise get from our flake.

There are various ways to fetch this repository without flakes and all are interchangable in any kind of usage.

Examples:

```nix
{
  nixpkgs.overlays = [ (import (builtins.fetchGit { url = "ssh://git@github.com/notgne2/osu-nixos.git"; rev = "[latest Git revision from here]"; })).overlay ];
}
```

```nix
{
  environment.systemPackages = [ (import (builtins.fetchTarball "https://github.com/notgne2/osu-nixos/archive/refs/heads/master.tar.gz")).packages.${pkgs.system}.osu-lazer ];
}
```

## Cause

The osu! developers appear to either be hiding an important secret or be somewhat ignorant, for better or for worse I am going to apply Hanlon's razor here. It seems like it is a very dull way of tricking themselves into thinking cheating is harder. They later claim that it is was for checking versions, though I am going to give them the benefit of the doubt and assume they are lying, and they do not think that a build hash is better than a version number for checking versions.

With every binary build they release, they will produce a hash of an internal game DLL file, and add it to their server's whitelist of acceptable hashes, and in the game's code is logic to produce this hash locally, and send it to the server for permission to use online components.

If you do not wish to use their upstream binary builds, then a patch is necessary. 

## The patch

You can view what the patch does in [./bypass-tamper-detection.patch](./bypass-tamper-detection.patch), but essentially it removes the logic to hash it's own game DLL file, and instead hardcodes a hash which is known to be accepted by their server.

You can find this hash yourself by extracting their distributed AppImage and producing an MD5 (lol) hash of `osu.Game.dll`.

## Related error

You can identify if you are affected by this bug if you see the error `You are not able to submit a score: invalid client hash` or similar, if you see this then make sure this patch is properly applied, otherwise you may need to update the hardcoded hash.
