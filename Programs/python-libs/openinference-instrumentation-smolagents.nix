{
  lib
, pkgs

  #! build-system
, setuptools
, hatchling
, python3Packages
}:


let
  pname = "openinference-instrumentation-smolagents";
  version = "0.1.6"; # Version is dynamic in pyproject.toml, using placeholder
in

  python3Packages.buildPythonPackage {
  inherit pname version;
  pyproject = true;

  src = pkgs.fetchFromGitHub {
    owner = "Arize-ai";
    repo = "openinference";
    rev = "main"; # You might want to use a specific tag/version when available
    hash =
    "sha256-gIjATT5tJsOuN7kfNRzRD38GIh6kBY7dXS/3d1gLmBw="
    # lib.fakeHash
    ;
  };

  # Extract only the relevant directory from the monorepo
  sourceRoot = "source/python/instrumentation/openinference-instrumentation-smolagents";

  nativeBuildInputs = with python3Packages; [
    wheel
    hatchling
    setuptools
    pythonRelaxDepsHook
    pythonRelaxDepsHook
  ];

  # Add this to explicitly bypass runtime checks for these packages
  doCheck = false;
  dontCheckRuntimeDeps = true;

  # Python version requirement from pyproject.toml
  pythonAtLeast = "3.10";
  pythonOlder = "3.14";

  pythonRelaxDeps = [
    "openinference-instrumentation"
    "openinference-semantic-conventions"
  ];

  propagatedBuildInputs = with python3Packages; [
    wrapt
    typing-extensions

    opentelemetry-api
    opentelemetry-instrumentation
    opentelemetry-semantic-conventions

    # openinference-instrumentation
    # openinference-semantic-conventions
  ];

  passthru.optional-dependencies = with python3Packages; {
    instruments = [
      smolagents
    ];
    test = [
      openai
      smolagents
      pytest-recording
      opentelemetry-sdk
    ];
  };

  # Check that the package can be imported
  pythonImportsCheck = [ "openinference.instrumentation.smolagents" ];

  meta = with lib; {
    homepage = "https://github.com/Arize-ai/openinference/tree/main/python/instrumentation/openinference-instrumentation-smolagents";
    description = "OpenInference smolagents Instrumentation";
    license = licenses.asl20; # Apache-2.0
    maintainers = with maintainers; [ offline ];
  };
}