#
# Basic Nix shell with CLI tools to develop winice.
#
{ buildEnv
, zip
, dotnetCorePackages
}:

with (import ./util.nix { inherit dotnetCorePackages; });

buildEnv {
  name = "winice-devenv";
  paths = [ zip  dot-sdk ];
}
