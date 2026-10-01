{
  lib,
  pkgs,
  fetchurl,
  fetchFromGitHub,
  buildPythonPackage,
  fetchPypi,

  # build-system
  setuptools,
  setuptools-scm,

  # Add dos2unix as a build dependency
  dos2unix,

  # dependencies
  accelerate,
  cut-cross-entropy,
  datasets,
  hf-transfer,
  huggingface-hub,
  packaging,
  peft,
  psutil,
  sentencepiece,
  torch,
  tqdm,
  transformers,
  trl,
  tyro,


  gguf,
  llama-cpp,

  # Add protobuf and pillow here
  protobuf,
  pillow,
  msgspec,

  curl,
  git,
}:

buildPythonPackage rec {
  pname = "unsloth-zoo";
  version = "2025.4.4";
  pyproject = true;

  src = fetchPypi {
    pname = "unsloth_zoo";
    inherit version;
    hash = "sha256-ywBd8H+pCmjzfCS8dpeA+73F8w/LYyYpeynXEEcsPNM=";
  };

  pythonRelaxDeps = [
    "protobuf"
  ];

  nativeBuildInputs = with pkgs; [
    dos2unix
  ];

    # if the Python code will still clone & build llama.cpp at runtime,
  # you may need to add these to `propagatedBuildInputs` or plain `buildInputs`
  # so that at runtime the `git` and `cmake` executables are in PATH:
  # propagatedBuildInputs = with pkgs; [
  #   git
  #   curl
  #   cmake
  # ];

  prePatch = ''
    dos2unix pyproject.toml
    dos2unix unsloth_zoo/__init__.py
    dos2unix unsloth_zoo/llama_cpp.py
  '';

  patches = [
    ./dont-require-sudo.patch
    ./dont-require-unsloth.patch
    ./fix-unsloth_zoo-license-spec.patch
    # ./fix-unsloth-zoo-llama-cpp.patch
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    accelerate
    cut-cross-entropy
    datasets
    hf-transfer
    huggingface-hub
    packaging
    peft
    psutil
    sentencepiece
    torch
    tqdm
    transformers
    trl
    tyro

    gguf
    llama-cpp

    # Add protobuf and pillow here to satisfy runtime deps
    protobuf
    pillow
    msgspec

  curl
  git

  ];

  doCheck = false;

  pythonImportsCheck = [
    "unsloth_zoo"
  ];

  meta = {
    description = "Utils for Unsloth";
    homepage = "https://github.com/unslothai/unsloth_zoo";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hoh ];
  };
}