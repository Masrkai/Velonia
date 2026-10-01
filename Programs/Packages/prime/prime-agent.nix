{
  lib,
  stdenv,
  buildNpmPackage,
  cmake,
  fetchFromGitHub,
  fetchzip,
  autoPatchelfHook,
  bash,
  cacert,
  cairo,
  fd,
  git,
  gnutar,
  jq,
  makeWrapper,
  ninja,
  nodejs,
  npm-lockfile-fix,
  pango,
  pkg-config,
  python311,
  ripgrep,
  uv,
  versionCheckHook,
  xdg-utils,
  zeromq,
}:

let
  runtimePath = [
    nodejs
    bash
    fd
    git
    ripgrep
    gnutar
    uv
    python311
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ xdg-utils ];

  # The zeromq npm package ships prebuilt native addons, so the addon is built
  # from source against nixpkgs' libzmq instead.
  projectOptions = fetchzip {
    url = "https://github.com/aminya/project_options/archive/refs/tags/v0.41.0.zip";
    hash = "sha256-qZusLCSdzHHQ7XN7wGcroWGyDvNVYphojbTUre0od7s=";
  };

  cmakeTsOptions = builtins.toJSON {
    "cmake-ts" = {
      cmakeOptions = [
        {
          name = "FETCHCONTENT_SOURCE_DIR__PROJECT_OPTIONS";
          value = "$ROOT$/project_options";
        }
      ]
      ++ lib.optionals stdenv.hostPlatform.isDarwin [
        {
          name = "MACOSX_DEPLOYMENT_TARGET";
          value = "10.15";
        }
      ];
    };
  };
in
buildNpmPackage (finalAttrs: {
  pname = "prime-agent";
  version = "0.7.1";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "PrimeIntellect-ai";
    repo = "prime-agent";
    rev = "95afd319a78ae017a41241d50b013d656a0685ce";
    hash = "sha256-0QheD6herrWiLxEugmQytSJ0yd48SY+k7uDHiS88AoA=";
    # The upstream lockfile omits registry metadata for workspace dependencies.
    postFetch = ''
      ${lib.optionalString stdenv.hostPlatform.isDarwin "export REQUESTS_CA_BUNDLE=${cacert}/etc/ssl/certs/ca-bundle.crt"}
      ${lib.getExe npm-lockfile-fix} $out/package-lock.json
    '';
  };

  patches = [
    # Bootstrap runs `uv python install 3.11` explicitly when no
    # venv exists yet (bootstrap.ts), which downloads a Python that is
    # never used because the venv is created with the Python provided by nix
    # (UV_PYTHON_PREFERENCE=system). Drop the redundant download.
    ./remove-uv-python-install.patch
  ];

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-B+mwGIZ5lTr2/+lTAvyeJDtsIigPSnkMByIoJrxCq9Q=";

  # The zeromq addon is built from source in buildPhase; don't let `npm rebuild`
  # touch install scripts (they would try to load the shipped prebuilt addons,
  # which are broken on aarch64-darwin, or attempt a networked build).
  npmRebuildFlags = [ "--ignore-scripts" ];

  nativeBuildInputs = [
    cmake
    jq
    makeWrapper
    ninja
    pkg-config
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];

  buildInputs = [
    cairo
    pango
    # The npm addon is compiled with zeromq's draft APIs enabled (upstream
    # default) and references draft symbols, so the libzmq it links against
    # must have them too; otherwise the addon fails to load.
    (zeromq.override { enableDrafts = true; })
  ];

  dontConfigure = true;
  # Build the workspace packages explicitly because the root package is not the CLI.
  dontNpmBuild = true;
  buildPhase = ''
    runHook preBuild

    export PATH="$PWD/node_modules/.bin:$PATH"
    npm --workspace packages/tui run build
    (cd packages/ai && tsgo -p tsconfig.build.json)
    npm --workspace packages/agent run build
    npm --workspace packages/coding-agent run build

    # Build the zeromq native addon from source against nixpkgs' libzmq;
    # Strip the vcpkg call (which would fetch and build its own libzmq)
    # and let zeromq's own cmake-ts build do the rest, fully offline.
    sed -i '/run_vcpkg/,/)/d' node_modules/zeromq/CMakeLists.txt
    mkdir -p node_modules/zeromq/project_options
    cp -r ${projectOptions}/. node_modules/zeromq/project_options/
    ${lib.toShellVar "cmakeTsOptions" cmakeTsOptions}
    jq --argjson opts "$cmakeTsOptions" '. * $opts' \
      node_modules/zeromq/package.json > node_modules/zeromq/package.json.tmp
    mv node_modules/zeromq/package.json.tmp node_modules/zeromq/package.json

    # cmake-ts downloads node headers; give it nixpkgs' instead.
    nodever=$(node -p process.versions.node)
    os=$(node -p process.platform)
    arch=$(node -p process.arch)
    mkdir -p "$HOME/.cmake-ts/node/$os/$arch/v$nodever/include"
    cp -r ${nodejs}/include/node "$HOME/.cmake-ts/node/$os/$arch/v$nodever/include/"
    export CMAKE_PREFIX_PATH="$NIXPKGS_CMAKE_PREFIX_PATH"

    # Drop the shipped prebuilt addons so the loader only finds our build.
    rm -rf node_modules/zeromq/build/*/
    (cd node_modules/zeromq && npm_config_build_from_source=true node script/install.js)
    rm -rf node_modules/zeromq/staging node_modules/zeromq/compile_commands.json

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    npm prune --omit=dev --ignore-scripts
    packageDir=$out/lib/prime-agent
    mkdir -p "$packageDir" $out/bin
    cp -R node_modules "$packageDir/node_modules"
    rm -rf "$packageDir/node_modules/koffi"
    cp packages/coding-agent/package.json "$packageDir/package.json"
    cp -R packages/coding-agent/dist "$packageDir/dist"
    for path in README.md CHANGELOG.md docs examples skills; do
      cp -R "packages/coding-agent/$path" "$packageDir/$path"
    done

    mkdir -p "$packageDir/packages"
    for workspace in ai agent tui coding-agent; do
      mkdir -p "$packageDir/packages/$workspace"
      cp "packages/$workspace/package.json" "$packageDir/packages/$workspace/package.json"
      cp -R "packages/$workspace/dist" "$packageDir/packages/$workspace/dist"
    done
    for path in docs examples skills; do
      cp -R "packages/coding-agent/$path" "$packageDir/packages/coding-agent/$path"
    done

    # The venv is created with the Python provided by nix (UV_PYTHON_PREFERENCE=system).
    # UV_PYTHON_DOWNLOADS=manual stops any surprise Python downloads.
    makeWrapper ${lib.getExe nodejs} $out/bin/prime-agent \
      --add-flags "$packageDir/dist/bundle/cli.js" \
      --set PI_PACKAGE_DIR "$packageDir" \
      --set PI_SKIP_VERSION_CHECK 1 \
      --set UV_PYTHON_PREFERENCE system \
      --set UV_PYTHON_DOWNLOADS manual \
      --prefix PATH : ${lib.makeBinPath runtimePath} \
      ${lib.optionalString stdenv.hostPlatform.isLinux "--prefix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath [ stdenv.cc.cc.lib ]
      }"}

    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "--version";

  installCheckPhase = ''
    runHook preInstallCheck

    # Verify the Python version matches what the source code requires
    requiredPythonVersion=$(grep -oP 'PYTHON_VERSION = "\K[^"]+' \
      packages/coding-agent/src/core/kernel/bootstrap.ts)
    actualVersion=$(${lib.getExe python311} -c 'import sys;print("%d.%d"%sys.version_info[:2])')
    if [ "$actualVersion" != "$requiredPythonVersion" ]; then
      echo "ERROR: prime-agent requires Python $requiredPythonVersion but $actualVersion provided"
      exit 1
    fi

    runHook postInstallCheck
  '';

  meta = {
    description = "Self-improving RLM coding and research agent";
    homepage = "https://github.com/PrimeIntellect-ai/prime-agent";
    changelog = "https://github.com/PrimeIntellect-ai/prime-agent/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.okwilkins ];
    mainProgram = "prime-agent";
    platforms = [
      "aarch64-linux"
      "x86_64-linux"
      "aarch64-darwin"
    ];
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})