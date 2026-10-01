{
  lib,
  config,
  stdenv,
  blas,
  lapack,
  buildPythonPackage,
  fetchurl,
  cudaSupport ? config.cudaSupport,

  # build-system
  setuptools,

  # dependencies
  jaxlib,
  ml-dtypes,
  numpy,
  opt-einsum,
  scipy,

  # optional-dependencies
  jax-cuda12-plugin,

  # tests
  cloudpickle,
  hypothesis,
  matplotlib,
  pytestCheckHook,
  pytest-xdist,

  # passthru
  callPackage,
  jax,
  jaxlib-build,
  jaxlib-bin,
}:

let
  usingMKL = blas.implementation == "mkl" || lapack.implementation == "mkl";
in
buildPythonPackage rec {
  pname = "jax";
  version = "0.8.1";
  format = "wheel";

  src = fetchurl {
    #! old

    # url = "https://files.pythonhosted.org/packages/31/25/32c5e2c919da4faaea9ef5088437ab6e01738c49402e4ec8a6c7b49e30ef/jax-0.6.0-py3-none-any.whl";
    # hash = "sha256-IrIYJ1l8bWtG6IVDtPw3L83fHMEkdmBFLeAgzEvaGvw=";

    # url = "https://files.pythonhosted.org/packages/f9/e7/19b8cfc8963b2e10a01a4db7bb27ec5fa39ecd024bc62f8e2d1de5625a9d/jax-0.8.1-py3-none-any.whl" ;
    # hash = "sha256-TL3FVI8wlc3WnTjkM3lQsvwfJQp0CgI00ZDkoxkHdWQ=";

    url = "https://files.pythonhosted.org/packages/70/aa/dfac6d72cc35bc07e7587115b6946e333ef4ccb2e6cd26ecf639438c5d26/jax-0.10.0-py3-none-any.whl";
    hash = "sha256-dsQroWPI2z3C5EniJbiIwO37Yj3tMe/cltheD9odJug=";
    # hash = lib.fakeHash;  # You'll need to update this hash
  };

  dependencies = [
    jaxlib
    ml-dtypes
    numpy
    opt-einsum
    scipy
  ]
  ++ lib.optionals cudaSupport optional-dependencies.cuda;

  optional-dependencies = rec {
    cuda = [ jax-cuda12-plugin ];
    cuda12 = cuda;
    cuda12_pip = cuda;
    cuda12_local = cuda;
  };

  nativeCheckInputs = [
    cloudpickle
    hypothesis
    matplotlib
    pytestCheckHook
    pytest-xdist
  ];

  doCheck = false;

  pythonImportsCheck = [ "jax" ];
  passthru.tests = {
    test_cuda_jaxlibBin = callPackage ./test-cuda.nix {
      jax = jax.override { jaxlib = jaxlib-bin; };
    };
  };

  # updater fails to pick the correct branch
  passthru.skipBulkUpdate = true;

  meta = {
    description = "JAX frontend (pre-built wheel): differentiate, compile, and transform Numpy code";
    homepage = "https://github.com/google/jax";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [
      GaetanLepage
      samuela
    ];
  };
}
