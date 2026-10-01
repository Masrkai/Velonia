{
  # Nix
  lib, fetchFromGitHub, buildPythonPackage,

  # Build systems
  cmake, pkg-config, python,

  # libs
  libsndfile, zlib, libpng, libjpeg, tbb, sentencepiece, onnx
, pybind11, libzip

}:

buildPythonPackage rec {
  pname = "fairseq2";
  version = "0.5.2";

  src = fetchFromGitHub {
    owner = "facebookresearch";
    repo = "fairseq2";
    rev = "v${version}";
    hash = "sha256-y9BJgqoW6u9EwSr14RJEmFVW8lsoSKDCAs+8Ho3HDgI=";
    fetchSubmodules = true;
  };

  # C/C++ build tools
  nativeBuildInputs = [ cmake pkg-config ];

  # Non-Python libraries to link against (explicitly listed per Nix policy)
  buildInputs = [
    tbb             # Threading Building Blocks (for parallelism)
    libsndfile      # audio file reading
    zlib            # compression
    libpng          # PNG image support
    libjpeg         # JPEG image support
    sentencepiece   # subword tokenizer library
    libzip          # zip file support
    pybind11        # C++/Python binding library
    onnx            # ONNX model support (if needed)
  ];

  # Python dependencies (from nixpkgs): numpy, PyTorch, etc.
  propagatedBuildInputs = with python; [
    numpy
    natsort
    torch        # PyTorch (C++/CUDA backend)
    transformers # (example extra, adjust as needed)
    # ... add other required Python deps here ...
  ];

  # Patch out any external CMake projects so we use Nix-provided libraries
  patches = [
    ./fix-cmake-use-system-libs.patch
  ];

  # Force the use of Python 3.12 (fairseq2 requires ≥3.10:contentReference[oaicite:4]{index=4})
  # python = python312Packages.python;

  meta = with lib; {
    description = "FAIR sequence modeling toolkit (Python/C++)";
    homepage    = "https://github.com/facebookresearch/fairseq2";
    license     = licenses.mit;
    platforms   = platforms.linux ++ platforms.darwin;
  };
}
