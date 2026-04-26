#
# Build a framework-dependent release and zip it up.
# This build targets environments where the .NET 10 (or above) runtime
# has **already** been installed. The Nix derivation's output contains
#
# - `bin` dir. The files output by the `dotnet publish` command.
# - `winice_M.m.p.zip` bundle. (`M.m.p` is the sem ver number, eg.
#   `winice_2.0.1.zip`.) Zip file containing a directory named
#   `winice_M.m.p` (eg. `winice_2.0.1`) with all the files in
#   `bin`.
# - `winice_M.m.p.sha256` hash. Text file with the SHA-256 hash of
#   the zip bundle.
#
# You can run winice using the platform-specific executable (either
# `nice` or `nice.exe`) straight from the `bin` dir or after extracting
# the zip file contents. Notice the exe will blow if it can't find the
# .NET runtime---that can only happen if you have a custom install. To
# get around it, just set the `DOTNET_ROOT` env var as in the example
# below.
#
# $ export DOTNET_ROOT=/nix/store/n21rkb42padh3wjswm7vd55cra0mb7c0-winice-devenv/share/dotnet
# $ nix build .#winice-bare-osx-arm64
# $ result/bin/nice
#
# See also:
# - https://learn.microsoft.com/en-us/dotnet/core/deploying/?pivots=cli#framework-dependent-deployment
#
{ stdenv
, zip
, dotnetCorePackages
, rid
}:

with (import ./util.nix { inherit dotnetCorePackages; });

stdenv.mkDerivation rec {

  inherit pname version src;

  buildInputs = [ zip dot-sdk ];

  buildPhase = ''
    dotnet publish nice/nice.csproj \
      ${build-flags.version} \
      --runtime ${rid} \
      ${build-flags.release}
  '';

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/${winice-root}

    cp -r ${dotnetPubDir rid}/* $out/bin/
    cp -r ${dotnetPubDir rid}/* $out/${winice-root}/

    cd $out/
    zip -r ${winice-root}.zip ${winice-root}
    sha256sum ${winice-root}.zip > ${winice-root}.sha256
    rm -rf ${winice-root}/
  '';

}
# NOTE
# ----
# 1. Automagic NuGet config. There's an extra `configureNuget` task
# that runs just before the build---probably inserted by the .NET SDK
# Nix expression. Here's what it does:
# - adds these vars to env
#   `NUGET_PACKAGES=/tmp/nix-shell.Y3mOVF/nuget.MGnNET/packages/`
#   `NUGET_FALLBACK_PACKAGES=/tmp/nix-shell.Y3mOVF/nuget.MGnNET/fallback/`
# - creates nuget.config w/
# ```xml
#   <packageSources>
#     <clear/>
#     <add key="_nix" value="/tmp/nix-shell.Y3mOVF/nuget.P9F1z4/source"/>
#   </packageSources>
#   <packageRestore>
#     <clear/>
#   </packageRestore>
# ```
