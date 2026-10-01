{
  lib,
  stdenv,
  buildPythonPackage,
  pythonOlder,
  fetchFromGitHub,
  which,
  setuptools,
  # runtime dependencies
  numpy,
  torch,
  # check dependencies
  pytestCheckHook,
  pytest-cov-stub,
  # , pytest-mpi
  pytest-timeout,
  # , pytorch-image-models
  hydra-core,
  fairscale,
  scipy,
  cmake,
  ninja,
  triton,
  networkx,
  #, apex
  einops,
  transformers,
  timm,
#, flash-attn
}:
let
  inherit (torch) cudaCapabilities cudaPackages cudaSupport;
  version = "0.0.28.post3";
in
buildPythonPackage {
  pname = "xformers";
  inherit version;
  pyproject = true;

  disabled = pythonOlder "3.9";

  src = fetchFromGitHub {
    owner = "facebookresearch";
    repo = "xformers";
    tag = "v${version}";
    hash = "sha256-23tnhCHK+Z0No8fqZxkgDFp2VIgXZR4jpM+pkb/vvmw=";
    fetchSubmodules = true;
  };

  patches = [
              ./patches/xformers/0001-fix-allow-building-without-git.patch


    ];

  build-system = [ setuptools ];

  # Limit parallel jobs to reduce memory usage - each job can use 4-8GB RAM
  # With 48GB RAM, limit to 2-3 jobs to stay safe
  enableParallelBuilding = false;  # Disable Nix's parallel building
  
  preBuild = ''
    cat << EOF > ./xformers/version.py
    # noqa: C801
    __version__ = "${version}"
    EOF

    # Limit MAX_JOBS to 2 to prevent OOM (instead of $NIX_BUILD_CORES)
    # Each xformers compilation job can use 4-8GB of RAM
    export MAX_JOBS=2
    
    # Also limit ninja parallel jobs as a backup
    export NINJA_STATUS="[%f/%t] "
    
    # Set memory-conscious compilation flags
    export CXXFLAGS="''${CXXFLAGS:-} -g0"  # Remove debug symbols to save memory
    export CFLAGS="''${CFLAGS:-} -g0"
  '';

  env = lib.attrsets.optionalAttrs cudaSupport {
    TORCH_CUDA_ARCH_LIST = "${lib.concatStringsSep ";" torch.cudaCapabilities}";
  };

  stdenv = if cudaSupport then cudaPackages.backendStdenv else stdenv;

  buildInputs = lib.optionals cudaSupport (
    with cudaPackages;
    [
      # flash-attn build
      cuda_cudart # cuda_runtime_api.h
      libcusparse # cusparse.h
      cuda_cccl # nv/target
      libcublas # cublas_v2.h
      libcusolver # cusolverDn.h
      libcurand # curand_kernel.h
    ]
  );

  nativeBuildInputs = [
    ninja
    which
  ] ++ lib.optionals cudaSupport (with cudaPackages; [ cuda_nvcc ]);

  dependencies = [
    numpy
    torch
  ];

  pythonImportsCheck = [ "xformers" ];

  # Has broken 0.03 version:
  # https://github.com/NixOS/nixpkgs/pull/285495#issuecomment-1920730720
  passthru.skipBulkUpdate = true;

  dontUseCmakeConfigure = true;

  # see commented out missing packages
  doCheck = false;

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
    pytest-timeout
    hydra-core
    fairscale
    scipy
    cmake
    networkx
    triton
    # apex
    einops
    transformers
    timm
    # flash-attn
  ];

  meta = with lib; {
    description = "Collection of composable Transformer building blocks";
    homepage = "https://github.com/facebookresearch/xformers";
    changelog = "https://github.com/facebookresearch/xformers/blob/${version}/CHANGELOG.md";
    license = licenses.bsd3;
    maintainers = with maintainers; [ happysalada ];
  };
}