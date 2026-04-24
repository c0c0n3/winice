Nix Winice Env
--------------
> Reproducible dev env and local-first CI/CD.

We use Nix to reliably build Winice on any machine Nix supports.
You should install Nix if you don't have it yet:
- https://docs.determinate.systems/

Winice's Nix shell drops you into a dev env with the .NET toolchain:

```bash
$ cd nix
$ nix shell
$ cd ..
```

Now you can run a basic build

```bash
$ dotnet build nice/nice.csproj
```

or something fancier

```bash
$ dotnet restore nice/nice.csproj
# ~~> download packages for the current system in ~/.nuget and generate a
#     corresponding nice/packages.lock.json
$ dotnet restore nice/nice.csproj --runtime win-x64 \
    --lock-file-path packages.win-x64.lock.json \
    --packages build/dotnet-pkgs
# ~~> download packages for win-x64 in ./build/dotnet-pkgs and generate a
#     corresponding nice/packages.win-x64.lock.json
```

To see what Nix packages you can build, run

```bash
$ cd nix
$ nix flake show
```

To print the build command for a Winice Nix package:

```bash
$ nix develop .#winice-bare-osx-arm64 --command bash -c 'printenv buildPhase'
dotnet publish nice/nice.csproj \
  -p:Version=2.0.0 \
  --runtime osx-arm64 \
  --configuration Release -p:ContinuousIntegrationBuild=true -p:Deterministic=true
```

Notice that the .NET toolchain we use to build Winice Nix packages
is exactly the same as that the Nix shell makes available. So for
example, running the following commands on macOS

```bash
$ cd nix
$ nix shell
$ dotnet publish nice/nice.csproj \
  -p:Version=2.0.0 \
  --runtime osx-arm64 \
  --configuration Release -p:ContinuousIntegrationBuild=true -p:Deterministic=true
```

will produce the same .NET artefacts as

```bash
$ cd nix
$ nix build .#winice-bare-osx-arm64
```
