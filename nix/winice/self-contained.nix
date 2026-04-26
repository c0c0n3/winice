#
# Build a self-contained release.
# This build targets any environment where .NET 10 can run. The whole
# .NET 10 runtime and dependent libs are bundled in a single executable.
# The Nix derivation's output contains
#
# - `nice.exe` (Windows) or `nice` (other platforms) binary. The executable
#    file output by the `dotnet publish` command.
# - `nice.sha256` hash. Text file with the SHA-256 hash of the binary.
#
# You can run winice by executing directly the binary file.
#
# See also:
# - https://learn.microsoft.com/en-us/dotnet/core/deploying/?pivots=cli#self-contained-deployment
#
{ stdenv
, dotnetCorePackages
, rid
}:

with (import ./util.nix { inherit dotnetCorePackages; });

stdenv.mkDerivation rec {

  inherit pname version src;

  buildInputs = [ dot-sdk ];

  buildPhase = ''
    dotnet publish nice/nice.csproj \
      ${build-flags.version} \
      --runtime ${rid} \
      ${build-flags.release} \
      -p:SelfContained=true \
      -p:PublishSingleFile=true \
      -p:PublishTrimmed=false
  '';

  installPhase = ''
    mkdir -p $out

    cp ${dotnetPubDir rid}/nice* $out/
    cd $out
    sha256sum nice* > nice.sha256
  '';

}
# NOTE
# ----
# 1. Why `nice*`? Depending on the platform, the binary could be named
# `nice.exe` (Windows) or just `nice` (other platforms). So we use a glob
# to cater for both names.
#
# 2. Trimming. Not worth the trouble. Winice is tiny at the moment and
# the self-contained file is about 75MB. Trimming brings down the file
# size to 15MB, but also introduces some weird behaviour. For example,
#
# $ nix build .#winice-osx-arm64
# $ result/nice -n 10 eza -l result/
# .r-xr-xr-x 76M root  1 Jan  1970 nice
# .r--r--r--  71 root  1 Jan  1970 nice.sha256
# nice: Cannot process request because the process (21194) has exited.
#
# The docs do say trimming can cause trouble. Let's leave it at that.
# See:
# - https://learn.microsoft.com/en-us/dotnet/core/deploying/trimming/trim-self-contained
#
# 3. Why not use `buildDotnetModule`? Yeah, we could do that in the
# future---see `self-contained.alt.nix`. But right now, it seems to
# me it might cause extra headaches for the kind of cross-compiling
# we'd like to do.
#
# 4. Automagic NuGet config. See note in `framework-dependent-zip.nix`.
