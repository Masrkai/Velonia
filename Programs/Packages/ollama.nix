{ lib
, buildGoModule
, fetchFromGitHub
, buildEnv
, linkFarm
, makeWrapper
, stdenv
, addDriverRunpath
, nix-update-script

, cmake
, gitMinimal
, clblast
, libdrm
, rocmPackages
, rocmGpuTargets ? rocmPackages.clr.gpuTargets or [ ]
, cudaPackages
, cudaArches ? cudaPackages.cudaFlags.realArches or [ ]
, darwin
, autoAddDriverRunpath

, nixosTests
, testers
, ollama
, ollama-rocm
, ollama-cuda

, config
, acceleration ? null

, overrideCC
, gcc
}:

assert builtins.elem acceleration [ null false "rocm" "cuda" ];

let
  validateFallback = lib.warnIf (config.rocmSupport && config.cudaSupport)
    (lib.concatStrings [
      "both `nixpkgs.config.rocmSupport` and `nixpkgs.config.cudaSupport` are enabled, "
      "but they are mutually exclusive; falling back to cpu"
    ]) (!(config.rocmSupport && config.cudaSupport));

  shouldEnable = mode: fallback:
    (acceleration == mode) || (fallback && acceleration == null && validateFallback);

  rocmRequested = shouldEnable "rocm" config.rocmSupport;
  cudaRequested = shouldEnable "cuda" config.cudaSupport;

  enableRocm = rocmRequested && stdenv.hostPlatform.isLinux;
  enableCuda = cudaRequested && stdenv.hostPlatform.isLinux;

  rocmLibs = [
    rocmPackages.clr
    rocmPackages.hipblas-common
    rocmPackages.hipblas
    rocmPackages.rocblas
    rocmPackages.rocsolver
    rocmPackages.rocsparse
    rocmPackages.rocm-device-libs
    rocmPackages.rocm-smi
  ];

  rocmPath = buildEnv {
    name  = "rocm-path";
    paths = rocmLibs;
  };

  cudaLibs = [
    cudaPackages.cuda_cudart
    cudaPackages.libcublas
    cudaPackages.cuda_cccl
  ];

  cudaMajorVersion = lib.versions.major cudaPackages.cuda_cudart.version;

  cudaToolkit = buildEnv {
    name  = "cuda-merged-${cudaMajorVersion}";
    paths = map lib.getLib cudaLibs ++ [
      (lib.getOutput "static" cudaPackages.cuda_cudart)
      (lib.getBin (cudaPackages.cuda_nvcc.__spliced.buildHost or cudaPackages.cuda_nvcc))
    ];
  };

  cudaPath = lib.removeSuffix "-${cudaMajorVersion}" cudaToolkit;

  metalFrameworks = with darwin.apple_sdk_11_0.frameworks; [
    Accelerate
    Metal
    MetalKit
    MetalPerformanceShaders
  ];

  wrapperOptions =
    [ "--suffix LD_LIBRARY_PATH : '${addDriverRunpath.driverLink}/lib'" ]
    ++ lib.optionals enableRocm [
      "--suffix LD_LIBRARY_PATH : '${rocmPath}/lib'"
      "--set-default HIP_PATH '${rocmPath}'"
    ]
    ++ lib.optionals enableCuda [
      "--suffix LD_LIBRARY_PATH : '${lib.makeLibraryPath (map lib.getLib cudaLibs)}'"
    ];

  wrapperArgs = builtins.concatStringsSep " " wrapperOptions;

  goBuild =
    if enableCuda then
      buildGoModule.override { stdenv = cudaPackages.backendStdenv; }
    else if enableRocm then
      buildGoModule.override { stdenv = rocmPackages.stdenv; }
    else
      buildGoModule.override { stdenv = overrideCC stdenv gcc; };

in
goBuild (finalAttrs: {
  pname    = "ollama";
  version  = "0.6.6";

  src = fetchFromGitHub {
    owner          = "ollama";
    repo           = "ollama";
    tag            = "v${finalAttrs.version}";
    rev            = null;
    hash           = "sha256-9ZkO+LrS9rOTgOW8chLO3tnbne/+BSxQY+zOsSoE5Zc=";
    fetchSubmodules = true;
  };

  vendorHash = "sha256-4wYgtdCHvz+ENNMiHptu6ulPJAznkWetQcdba3IEB6s=";

  env = lib.optionalAttrs enableRocm {
    ROCM_PATH  = rocmPath;
    CLBlast_DIR = "${clblast}/lib/cmake/CLBlast";
    HIP_PATH   = rocmPath;
    CFLAGS     = "-Wno-c++17-extensions -I${rocmPath}/include";
    CXXFLAGS   = "-Wno-c++17-extensions -I${rocmPath}/include";
    HIP_ARCHS  = lib.concatStringsSep ";" rocmGpuTargets;
  };

  nativeBuildInputs =
    [ cmake gitMinimal ]
    ++ lib.optionals enableRocm (rocmPackages.llvm.bintools ++ rocmLibs)
    ++ lib.optionals enableCuda [ cudaPackages.cuda_nvcc ]
    ++ lib.optionals (enableRocm || enableCuda) [ makeWrapper autoAddDriverRunpath ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin metalFrameworks;

  buildInputs =
    lib.optionals enableRocm (rocmLibs ++ [ libdrm ])
    ++ lib.optionals enableCuda cudaLibs
    ++ lib.optionals stdenv.hostPlatform.isDarwin metalFrameworks;

  postPatch = ''
    substituteInPlace version/version.go --replace-fail 0.0.0 '${finalAttrs.version}'
  '';

  overrideModAttrs = final: prev: { preBuild = ""; };

  preBuild = let
      removeSMPrefix = str:
        let m = builtins.match "sm_(.*)" str; in
        if m == null then str else builtins.head m;
      cudaArchs = builtins.concatStringsSep ";" (builtins.map removeSMPrefix cudaArches);
      rocmTargets = builtins.concatStringsSep ";" rocmGpuTargets;
      cmakeCuda  = lib.optionalString enableCuda "-DCMAKE_CUDA_ARCHITECTURES='${cudaArchs}'";
      cmakeRocm  = lib.optionalString enableRocm "-DAMDGPU_TARGETS='${rocmTargets}'";
    in ''
      cmake -B build \
        -DCMAKE_SKIP_BUILD_RPATH=ON \
        -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
        ${cmakeCuda} \
        ${cmakeRocm}
      cmake --build build -j $NIX_BUILD_CORES
    '';

  postInstall = ''
    mkdir -p $out/lib
    cp -r build/lib/ollama $out/lib/
  '';

  postFixup = ''
    mv "$out/bin/app" "$out/bin/.ollama-app"
    wrapProgram "$out/bin/ollama"
      --prefix LD_LIBRARY_PATH : "${stdenv.cc.cc.lib}/lib"
      ${wrapperArgs}
  '';

  ldflags = [
    "-s"
    "-w"
    "-X=github.com/ollama/ollama/version.Version=${finalAttrs.version}"
    "-X=github.com/ollama/ollama/server.mode=release"
  ];

  __darwinAllowLocalNetworking = true;

  sandboxProfile = lib.optionalString stdenv.hostPlatform.isDarwin ''
    (allow file-read* (subpath "/System/Library/Extensions"))
    (allow iokit-open (iokit-user-client-class "AGXDeviceUserClient"))
  '';

  passthru = {
    tests = {
      inherit ollama;
      version = testers.testVersion {
        inherit (finalAttrs) version;
        package = ollama;
      };
    };
    inherit ollama-rocm ollama-cuda;
    service      = nixosTests.ollama;
    service-cuda = nixosTests.ollama-cuda;
    service-rocm = nixosTests.ollama-rocm;
  };

  meta = with lib; {
    description = "Get up and running with large language models locally"
      + lib.optionalString rocmRequested ", using ROCm for AMD GPU acceleration"
      + lib.optionalString cudaRequested ", using CUDA for NVIDIA GPU acceleration";
    homepage   = "https://github.com/ollama/ollama";
    changelog  = "https://github.com/ollama/ollama/releases/tag/v${finalAttrs.version}";
    license    = licenses.mit;
    platforms  = if (rocmRequested || cudaRequested) then platforms.linux else platforms.unix;
    mainProgram = "ollama";
    maintainers = with maintainers; [ abysssol dit7ya elohmeier prusnak ];
  };
})
