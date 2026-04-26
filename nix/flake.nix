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
    win = "x86_64-linux";    # run on: x86_64 Win 10 (or above) under WSL 2
    win-pkgs = import nixpkgs {
      system = win;
    };

    mkFwDepZip = pkgs: rid:
      pkgs.callPackage ./winice/framework-dependent-zip.nix {
        inherit rid;
      };
    mkSelfCont = pkgs: rid:
      pkgs.callPackage ./winice/self-contained.nix {
        inherit rid;
      };
  in {
    packages.${macos} = {
      default = macos-pkgs.callPackage ./winice/devenv.nix {};
      winice-fdd-osx-arm64 = mkFwDepZip macos-pkgs "osx-arm64";
      winice-scd-osx-arm64 = mkSelfCont macos-pkgs "osx-arm64";

      # cross-platform builds (not working at the mo)
      # winice-fdd-win-x64 = mkFwDepZip macos-pkgs "win-x64";
      # winice-fdd-win-arm64 = mkFwDepZip macos-pkgs "win-arm64";
      # winice-scd-win-x64 = mkSelfCont macos-pkgs "win-x64";
      # winice-scd-win-arm64 = mkSelfCont macos-pkgs "win-arm64";
    };
    packages.${win} = {
      default = win-pkgs.callPackage ./winice/devenv.nix {};
      winice-fdd-win-x64 = mkFwDepZip win-pkgs "win-x64";
      winice-scd-win-x64 = mkSelfCont win-pkgs "win-x64";

      # cross-platform builds (not working at the mo)
      # winice-fdd-win-arm64 = mkFwDepZip win-pkgs "win-arm64";
      # winice-fdd-osx-arm64 = mkFwDepZip win-pkgs "osx-arm64";
      # winice-scd-osx-arm64 = mkSelfCont win-pkgs "osx-arm64";
      # winice-scd-win-arm64 = mkSelfCont win-pkgs "win-arm64";
    };
  };
}
