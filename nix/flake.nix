{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
  let
    macos = "aarch64-darwin";    # run on: Apple silicon
    macos-pkgs = import nixpkgs {
      system = macos;
    };
    win = "x86_64-linux";    # run on: x86_64 Win 10 (or above) under WLS 2
    win-pkgs = import nixpkgs {
      system = win;
    };
  in {
    packages.${macos} = {
      winice = macos-pkgs.callPackage ./winice.nix { rid = "osx-arm64"; };
    };
    packages.${win} = {
      winice = win-pkgs.callPackage ./winice.nix { rid = "TODO"; };
      winice-osx-arm64 = macos-pkgs.callPackage ./winice.nix {
        rid = "osx-arm64";
      };
    };
  };
}