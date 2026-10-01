{
  lib,
  pkgs,
  packaging,
  fetchPypi,
  buildPythonPackage,

  # build-system
  glibc,
  ninja,
  setuptools,
  setuptools-scm,

  #CUDA
  cudatoolkit,
  addDriverRunpath,  # Added for CUDA runpath

  # Patch dependency
  dos2unix,

  # Ai deps
  trl,
  tyro,
  peft,
  datasets,
  xformers,
  diffusers,
  accelerate,
  hf-transfer,
  unsloth-zoo,
  bitsandbytes,
  transformers,
  sentencepiece,
  huggingface-hub,

    #? torch deps
    torch,
    torchvision,

    #? Required for GGUF
    gguf,
    llama-cpp,

  #! dependencies
  tqdm,
  numpy,
  protobuf,

  # cmake,
  curl,
  git,
}:

buildPythonPackage rec {
  pname = "unsloth";
  version = "2025.4.7";
  pyproject = true;

  src = fetchPypi {
    pname = "unsloth";
    inherit version;
    hash = "sha256-R5Z5s3E0hq8NdLN27u/mS70saz5265MtYlsQ4ddq0wY=";
  };

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    bitsandbytes
    numpy
    packaging
    torch
    unsloth-zoo
    xformers
    tyro
    transformers
    datasets
    sentencepiece
    tqdm
    accelerate
    trl
    peft
    protobuf
    huggingface-hub
    hf-transfer
    diffusers
    ninja
    torchvision

    gguf
    llama-cpp

    # cmake
    curl
    git
  ];

  pythonRelaxDeps = [
    "protobuf"
  ];

  nativeBuildInputs = [
    glibc
    dos2unix
    addDriverRunpath  # Added for CUDA runpath
  ];

  buildInputs = [
    cudatoolkit
    glibc
  ];

  prePatch = ''
    dos2unix pyproject.toml
  '';

  patches = [
    ./fix-unsloth-license-spec.patch
  ];

  # The source repository contains no test
  doCheck = false;

  # Importing requires a GPU, else the following error is raised:
  # NotImplementedError: Unsloth: No NVIDIA GPU found? Unsloth currently only supports GPUs!
  dontUsePythonImportsCheck = true;

  meta = {
    description = "Finetune Llama 3.3, DeepSeek-R1 & Reasoning LLMs 2x faster with 70% less memory";
    homepage = "https://github.com/unslothai/unsloth";
    changelog = "https://github.com/unslothai/unsloth/releases/tag/${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ offline ];
  };
}