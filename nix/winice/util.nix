#
# Shared Nix expressions used in several files.
# We factor them out to avoid duplication.
#
{ dotnetCorePackages }:
rec {
  pname = "winice";
  version = "2.0.0";

  src = ../../.;

  dot-sdk = dotnetCorePackages.dotnet_10.sdk;

  build-flags = {
    version = "-p:Version=${version}";                     # (1)
    release = "--configuration Release "
            + "-p:ContinuousIntegrationBuild=true "        # (2)
            + "-p:Deterministic=true";                     # (3)
  };
  dotnetPubDir = rid: "nice/bin/Release/net10.0/${rid}/publish";
  winice-root = "${pname}_${version}";

}
# NOTE
# ----
# 1. Artefacts version. We use the sem ver for versioning published
# artefacts and only keep the version number here---single source of
# truth. Passing the version prop to `dotnet publish` ensures DLLs,
# exe, etc. all have the same version.
# See:
# - https://andrewlock.net/version-vs-versionsuffix-vs-packageversion-what-do-they-all-mean/
#
# 2. Master build. `ContinuousIntegrationBuild` basically sets some
# props that apply to official builds on a CI server as opposed to
# local builds on a developer machine. Thanks to Nix, we have local
# CI/CD builds, so there's no difference between an official build on
# a CI server and one on a dev box. So we set this build prop to true.
# See:
# - https://learn.microsoft.com/en-us/dotnet/core/project-sdk/msbuild-props#continuousintegrationbuild
#
# 3. Deterministic build. Nix loves determinism. This flag "causes the
# compiler to produce an assembly whose byte-for-byte output is identical
# across compilations for identical inputs".
# See:
# - https://learn.microsoft.com/en-us/dotnet/csharp/language-reference/compiler-options/code-generation#deterministic
