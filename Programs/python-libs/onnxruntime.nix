{
  config,
  lib,
  fetchurl,
  buildPythonPackage,
  pythonOlder,
  autoPatchelfHook,
  stdenv,
  # Python dependencies
  coloredlogs,
  flatbuffers,
  numpy,
  packaging,
  protobuf,
  sympy,

  # CUDA support
  cudaSupport ? config.cudaSupport,
  cudaPackages ? { },
}:

let
  # Versions
  version = if cudaSupport then "1.23.0" else "1.23.1";
  pname = if cudaSupport then "onnxruntime-gpu" else "onnxruntime";

  # Get Python version (e.g., cp312)
  pythonVersion = let
    pyVer = numpy.pythonModule.pythonVersion;
    parts = lib.splitString "." pyVer;
    major = builtins.elemAt parts 0;
    minor = builtins.elemAt parts 1;
  in "cp${major}${minor}";

  platform = stdenv.hostPlatform.system;

  # Define wheel URLs and hashes
  wheelConfigs = {
    x86_64-linux = {
      cp312 = if cudaSupport then {
        # url = "https://files.pythonhosted.org/packages/3d/70/0178bfe5b729dd0d8f36c9cc0e7fc6b0d1ac660b43ff0cb278b235b1b671/onnxruntime_gpu-${version}-cp312-cp312-manylinux_2_27_x86_64.manylinux_2_28_x86_64.whl";
        url = "https://files.pythonhosted.org/packages/9d/96/e42de1a3a1cb6cb76bb5e98221c59fb8d954ca6929a6aff681d87c9fdca6/onnxruntime_gpu-${version}-cp312-cp312-manylinux_2_27_x86_64.manylinux_2_28_x86_64.whl";
        hash = "sha256-lYAURdS6T0QgWH5m1szygpSpzcMPVC2oQl32iscQH2I=";
        # hash = lib.fakeHash;
      } else {
        url = "https://files.pythonhosted.org/packages/c4/b0/4663a333a82c77f159e48fe8639b1f03e4a05036625be9129c20c4d71d12/onnxruntime-${version}-cp312-cp312-manylinux_2_27_x86_64.manylinux_2_28_x86_64.whl";
        hash = "sha256-V2UC2tcU/+XztOGRjFszaHZrIiBjxYXl/YhBXAY+TIA=";
      };
      cp313 = if cudaSupport then {
        url = "https://files.pythonhosted.org/packages/b1/7b/f2a9c043e2e5237cbddfcd34ec4f1c73a7f9c7d61f9e7b6a5673a7a7c541/onnxruntime_gpu-${version}-cp313-cp313-manylinux_2_27_x86_64.manylinux_2_28_x86_64.whl";
        hash = lib.fakeHash;
      } else {
        url = "https://files.pythonhosted.org/packages/5f/6e/53fa199c6a950cca80e41a6c9fb96cc6e9ea6bb7d82db40c26e4ee89d8b6/onnxruntime-${version}-cp313-cp313-manylinux_2_27_x86_64.manylinux_2_28_x86_64.whl";
        hash = lib.fakeHash;
      };
    };
  };

  wheelConfig = wheelConfigs.${platform}.${pythonVersion} or
    (throw "onnxruntime wheels not available for ${platform} with Python ${pythonVersion}");

in
buildPythonPackage rec {
  inherit pname version;
  format = "wheel";

  src = fetchurl {
    inherit (wheelConfig) url hash;
  };

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];

  buildInputs = lib.optionals cudaSupport (with cudaPackages; [
    cuda_cudart
    cudnn
    libcublas
    libcufft
    libcurand
    libcusparse
  ]);

  propagatedBuildInputs = [
    coloredlogs
    flatbuffers
    numpy
    packaging
    protobuf
    sympy
  ];

  pythonImportsCheck = [ (if cudaSupport then "onnxruntime" else "onnxruntime") ];

  doCheck = false;

  passthru = {
    inherit cudaSupport cudaPackages;
  };

  preFixup = ''
    echo "Removing TensorRT provider (libnvinfer/libnvonnxparser not available)..."
    rm -f $out/lib/python*/site-packages/onnxruntime/capi/libonnxruntime_providers_tensorrt.so || true
  '';

  meta = {
    description = "ONNX Runtime (${if cudaSupport then "GPU" else "CPU"} build)";
    homepage = "https://github.com/microsoft/onnxruntime";
    changelog = "https://github.com/microsoft/onnxruntime/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ puffnfresh ck3d cbourjau ];
    platforms = lib.platforms.linux;
  };
}
