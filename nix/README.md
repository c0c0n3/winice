Nix Winice Env
--------------
> Reproducible dev env and local-first CI/CD.

We use Nix to reliably build Winice on any machine Nix supports.
You should install Nix if you don't have it yet:
- https://docs.determinate.systems/

All the Bash commands below are meant to be run from the repo's
root dir.


### Dev env

Winice's Nix shell drops you into a dev env with the .NET toolchain:

```bash
$ nix shell nix/#
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


### Nix packages

To see what Nix packages you can build, run

```bash
$ nix flake show nix/
```

Package names have the following format:

- `winice-[deployment mode]-[target system]`

where deployment mode can be either `fdd` (framework-depended deployment)
or `scd` (self-contained deployment), and target system is one of
the following .NET RIDs: `win-x64`, `win-arm64`, `osx-arm64`.

To build a package for the same platform on which you're running the
build, pick the package with the RID corresponding to your platform.
For example, to build an FDD release on macOS (compiler's host) for
macOS (target), run

```bash
$ nix build nix/.#winice-fdd-osx-arm64
```

Notice that cross-compilation isn't working fully at the moment, so
you can't build a Nix package for a platform different than yours.
But there's a simple workaround, see the "Cross-compilation" section
below.

To print the build command for a Winice Nix package:

```bash
$ nix develop nix/.#winice-fdd-osx-arm64 --command bash -c 'printenv buildPhase'
dotnet publish nice/nice.csproj \
  -p:Version=2.0.0 \
  --runtime osx-arm64 \
  --configuration Release -p:ContinuousIntegrationBuild=true -p:Deterministic=true
```

Notice that the .NET toolchain we use to build Winice Nix packages
is exactly the same as that the Nix shell makes available. So for
example, running the following commands on macOS

```bash
$ nix shell nix/#
$ dotnet publish nice/nice.csproj \
  -p:Version=2.0.0 \
  --runtime osx-arm64 \
  --configuration Release -p:ContinuousIntegrationBuild=true -p:Deterministic=true
```

will produce the same .NET artefacts as

```bash
$ nix build nix/.#winice-fdd-osx-arm64
```


### Cross-compilation

To cross-compile an FDD package, enter the corresponding Nix package's
dev shell, then manually run the package's build and install phases.
For example, to cross-compile from macOS or Linux to Win x64, run:

```bash
$ nix develop nix/#winice-fdd-win-x64
$ export out="$(pwd)/build"
$ printenv buildPhase | bash
$ printenv installPhase | bash
$ eza -laT build/
```

To clean up:

```bash
$ git restore nice/packages.lock.json
$ rm -rf nice/bin nice/obj build
```

Cross-compiling an SCD package is basically the same. For example,
to cross-compile from macOS or Linux to Win x64, run:

```bash
$ nix develop nix/#winice-scd-win-x64
$ export out="$(pwd)/build"
$ printenv buildPhase | bash
$ printenv installPhase | bash
$ eza -laT build/
```

To clean up:

```bash
$ git restore nice/packages.lock.json
$ rm -rf nice/bin nice/obj build
```
