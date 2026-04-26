#
# Alternative Nix expression for the self-contained build.
# Based on the official (Nixpkgs) .NET build infra. Not used
# at the moment, but it might come in handy in the future.
#
{ dotnetCorePackages
, buildDotnetModule
, rid
}:

with (import ./util.nix { inherit dotnetCorePackages; });

buildDotnetModule {
  inherit pname version src;
  projectFile = "nice/nice.csproj";

  buildType = "Release";
  runtimeId = rid;
  dotnet-sdk = dot-sdk;

  # nugetDeps = ./deps.json;                               # (1)

  executables = [ "nice" ];                                # (2), (3)
  selfContainedBuild = true;
  # packNupkg = true;
}
# NOTE
# ----
# 1. Winice dependencies. We don't have any at the moment, but if
# we did, then you'd have to generate a `deps.json` file beforehand:
# - https://wiki.nixos.org/wiki/DotNET
# 2. Exe wrapping. The actual self-contained binary gets output under
# `$out/lib/winice/nice`, whereas `$out/bin/nice` is a Bash script that
# sets `DOTNET_ROOT` (not needed for a self-contained binary) and adds
# the ICU native lib (via `dotnet-sdk.icu`) to `LD_LIBRARY_PATH`---most
# likely a macOS-specific tweak. Our `self-contained.nix` build does no
# wrapping and the self-contained exe works as expected on macOS.
# See:
# - https://github.com/NixOS/nixpkgs/blob/dd1fb03f1b2337fdd43f182c7f90e18991d0dfca/pkgs/build-support/dotnet/build-dotnet-module/default.nix#L172
# 3. Exe name. Needs some tweaking. That's supposed to be `nice.exe`
# on Windows and `nice` on other platforms.
