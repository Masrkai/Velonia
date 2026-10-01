{
  lib,
  buildPythonPackage,
  fetchFromGitHub,

  # build-system
  hatchling,

  # dependencies
  docstring-parser,
  rich,
  shtab,
  typeguard,
  typing-extensions,

  # tests
  attrs,
  flax,
  jax,
  ml-collections,
  omegaconf,
  pydantic,
  pytestCheckHook,
  torch,
}:

buildPythonPackage rec {
  pname = "tyro";
  version = "0.9.18";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "brentyi";
    repo = "tyro";
    tag = "v${version}";
    hash = "sha256-EfcQIquO2rdR1pfRnYbjhQbiSGcIG2hCwXPodsa9aaA=";
  };

  build-system = [ hatchling ];

  dependencies = [
    docstring-parser
    rich
    shtab
    typeguard
    typing-extensions
  ];

  nativeCheckInputs = [
    attrs
    flax
    jax
    ml-collections
    omegaconf
    pydantic
    pytestCheckHook
    torch
  ];

  pythonImportsCheck = [ "tyro" ];

  # doCheck = false;

  meta = {
    description = "CLI interfaces & config objects, from types";
    homepage = "https://github.com/brentyi/tyro";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ offline ];
  };
}