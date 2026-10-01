{
  lib,
  stdenv,
  buildPythonPackage,
  fetchFromGitHub,
  pytestCheckHook,
  pythonAtLeast,

  # build-system
  setuptools,
  setuptools-scm,

  accelerate,
  build,
  datasets,
  deepspeed ? null,
  fire,
  huggingface-hub,
  pandas,
  pre-commit,
  pytest,
  pytest-sugar,
  pytest-xdist,
  torch,
  tqdm,
  transformers,
  twine,
}:

buildPythonPackage rec {
  pname = "cut-cross-entropy";
  version = "25.3.1";
  pyproject = true;

  # Python 3.13 support requires PyTorch 2.6, which is not merged yet
  # https://github.com/NixOS/nixpkgs/pull/377785
  disabled = pythonAtLeast "3.13";

  src = fetchFromGitHub {
    owner = "apple";
    repo = "ml-cross-entropy";
    rev = "24fbe4b5dab9a6c250a014573613c1890190536c"; # no tags
    hash = "sha256-BVPon+T7chkpozX/IZU3KZMw1zRzlYVvF/22JWKjT2Y=";
  };

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    torch
    # Remove triton from dependencies to avoid duplication; torch already includes it
  ];

  optional-dependencies = {
    test = [
      pytest
      pytest-sugar
      setuptools
    ];
    transformers = [ transformers ];
    all =
      [
        accelerate
        datasets
        fire
        huggingface-hub
        pandas
        tqdm
        transformers
      ]
      ++ lib.optionals (!stdenv.isDarwin) [
        deepspeed
      ];
    dev = [
      build
      pre-commit
      pytest-xdist
      twine
    ] ++ lib.flatten (lib.attrValues (lib.filterAttrs (n: v: n != "dev") optional-dependencies));
  };

  nativeCheckInputs = [ pytestCheckHook ];

  pythonImportsCheck = [
    "cut_cross_entropy"
  ];

  meta = {
    description = "Memory-efficient cross-entropy loss implementation using Cut Cross-Entropy (CCE)";
    homepage = "https://github.com/apple/ml-cross-entropy";
    # license = lib.licenses.aml;
    maintainers = with lib.maintainers; [ offline ];
  };
}