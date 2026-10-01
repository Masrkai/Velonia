{ lib
, python
, fetchFromGitHub
, buildPythonPackage
, cmake
, ninja
, pkg-config
, git
, nasm
, libsndfile
, flac
, libogg
, libvorbis
, libopus
, libiconv
, fmt
, sentencepiece
, libjpeg
, libpng
, zlib
, mpg123  # Added for libsndfile support
, cudaSupport ? false
, cudaPackages ? null
, cudaArchitectures ? [ "70-real" "70-virtual" ]
, imageSupport ? false
, useIntelTBB ? false
, tbb ? null
, stdenv
, pytorchVersion ? "2.8.0"
, doCheck ? false
, testDevice ? ""
, ...
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

  # System and build dependencies
  nativeBuildInputs = [ 
    cmake 
    ninja 
    pkg-config 
    git
    nasm
  ] ++ lib.optionals cudaSupport [
    cudaPackages.cuda_nvcc
    cudaPackages.cudatoolkit
  ];
  
  buildInputs = [ 
    libsndfile
    flac
    libogg
    libvorbis
    libopus
    libiconv
    fmt
    sentencepiece
    zlib
    mpg123  # Added for libsndfile support:cite[1]
  ] ++ lib.optionals imageSupport [
    libjpeg
    libpng
  ] ++ lib.optionals (useIntelTBB && tbb != null) [
    tbb
  ] ++ lib.optionals cudaSupport [
    cudaPackages.cuda_cudart
    cudaPackages.libcublas
    cudaPackages.libcusparse
  ];
  
  propagatedBuildInputs = with python.pkgs; [
    (if cudaSupport then pytorch-bin else pytorch)
    numpy
    packaging
    pyyaml
    typing-extensions
    tqdm
    omegaconf
    hydra-core
  ];

  # Use pyproject format since we're using CMake
  format = "pyproject";

  # Patch phase to use system dependencies
  patchPhase = ''
    cd native
    
    # Comment out third-party dependencies that we provide via Nix
    sed -i 's/^fairseq2n_add_fmt()/# fairseq2n_add_fmt()/' CMakeLists.txt
    sed -i 's/^fairseq2n_add_sentencepiece()/# fairseq2n_add_sentencepiece()/' CMakeLists.txt
    sed -i 's/^fairseq2n_add_kaldi_native_fbank()/# fairseq2n_add_kaldi_native_fbank()/' CMakeLists.txt
    sed -i 's/^fairseq2n_add_natsort()/# fairseq2n_add_natsort()/' CMakeLists.txt
    sed -i 's/^fairseq2n_add_zip()/# fairseq2n_add_zip()/' CMakeLists.txt
    sed -i 's/^fairseq2n_add_pybind11()/# fairseq2n_add_pybind11()/' CMakeLists.txt
    
    ${lib.optionalString (!imageSupport) ''
      sed -i 's/^fairseq2n_add_libjpeg_turbo()/# fairseq2n_add_libjpeg_turbo()/' CMakeLists.txt
      sed -i 's/^fairseq2n_add_libpng()/# fairseq2n_add_libpng()/' CMakeLists.txt
    ''}
    
    cd ..
  '';

  # Environment variables for CUDA if enabled
  preConfigure = lib.optionalString cudaSupport ''
    export CUDA_HOME=${cudaPackages.cudatoolkit}
    export CUDACXX=${cudaPackages.cuda_nvcc}/bin/nvcc
    export CMAKE_CUDA_ARCHITECTURES="${lib.concatStringsSep ";" cudaArchitectures}"
  '';

  # Configure phase
  configurePhase = ''
    runHook preConfigure
    
    cd native
    
    # Create a directory for CMake build
    mkdir -p build && cd build
    
    # Prepare CMAKE_PREFIX_PATH to include dependencies' development outputs
    local cmakePrefixPath=${lib.makeSearchPathOutput "dev" "lib" buildInputs}
    
    cmake -GNinja \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=$out \
      -DCMAKE_PREFIX_PATH="$cmakePrefixPath" \
      -DFAIRSEQ2N_USE_CUDA=${if cudaSupport then "ON" else "OFF"} \
      -DFAIRSEQ2N_SUPPORT_IMAGE=${if imageSupport then "ON" else "OFF"} \
      -DFAIRSEQ2N_THREAD_LIB=${if useIntelTBB then "tbb" else ""} \
      -DFAIRSEQ2N_BUILD_PYTHON_BINDINGS=ON \
      -DFAIRSEQ2N_PYTHON_DEVEL=ON \
      -DCMAKE_FIND_PACKAGE_PREFER_CONFIG=ON \
      -DBUILD_SHARED_LIBS=OFF \
      ${lib.optionalString cudaSupport "-DCMAKE_CUDA_ARCHITECTURES=\"${lib.concatStringsSep ";" cudaArchitectures}\""} \
      ..
    
    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild
    cmake --build . --parallel $NIX_BUILD_CORES
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    cmake --install .
    cd ../..
    # Install Python package using CMake's installation
    # The bindings should be installed by the CMake install command
    runHook postInstall
  '';

  inherit doCheck;
  checkPhase = lib.optionalString doCheck ''
    runHook preCheck
    ${python.interpreter} -c "import fairseq2; print('fairseq2 imported successfully')"
    ${lib.optionalString (testDevice != "") ''
      cd $out
      ${python.interpreter} -m pytest ${testDevice}
    ''}
    runHook postCheck
  '';

  pythonImportsCheck = [ "fairseq2" ];

  meta = with lib; {
    description = "FAIR Sequence Modeling Toolkit 2";
    homepage = "https://github.com/facebookresearch/fairseq2";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.unix;
    broken = (cudaSupport && !elem stdenv.hostPlatform.system [ "x86_64-linux" ]) ||
             (useIntelTBB && stdenv.hostPlatform.system != "x86_64-linux");
  };
}