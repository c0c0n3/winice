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

  version-prop = "-p:Version=${version}";                  # (1)
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
