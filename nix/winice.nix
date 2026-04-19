{ stdenv
, dotnetCorePackages
, rid
}:
stdenv.mkDerivation rec {

  pname = "winice";
  version = "3.2.1";

  src = ../.;

  buildInputs = [ dotnetCorePackages.dotnet_8.sdk ];

    # buildPhase = ''
    #   dotnet publish nice/nice.csproj \
    #     --configuration Release \
    #     /p:Version=${version} \
    #     -p:PublishSingleFile=true \
    #     --self-contained true \
    #     --runtime ${rid}
    # '';

    buildPhase = ''
      dotnet restore nice/nice.csproj  # --packages $src

      dotnet publish nice/nice.csproj \
        --no-restore \
        --configuration Release \
        /p:Version=${version} \
        -p:PublishSingleFile=true \
        --self-contained true \
        --runtime ${rid}
    '';

    installPhase = ''
      mkdir -p $out/bin
      cp nice/bin/Release/net8.0/${rid}/publish/nice* $out/bin/
      sha256sum build/bin/Release/nice* > $out/bin/nice.sha256
    '';

}
# NOTE
# ----
# version: https://andrewlock.net/version-vs-versionsuffix-vs-packageversion-what-do-they-all-mean/
# cater for `nice.exe` too
