{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    # Python and Jupyter
    python312
    python312Packages.jupyter
    python312Packages.pip
    python312Packages.ipykernel

    # UV package manager
    uv

    # Git for version control
    git
  ];

  shellHook = ''
    echo "Setting up Jupyter environment with UV..."

    # Get the Python path from Nix
    PYTHON_PATH=$(which python3)
    echo "Using Python: $PYTHON_PATH"
    python3 --version

    # Create virtual environment using uv with explicit Python version if it doesn't exist
    if [ ! -d ".venv" ]; then
      echo "Creating virtual environment with uv..."
      uv venv .venv --python $PYTHON_PATH
    fi

    # Activate virtual environment
    source .venv/bin/activate

    # Install/sync packages from requirements.txt if it exists
    if [ -f "requirements.txt" ]; then
      echo "Installing packages from requirements.txt using uv..."
      uv pip install -r requirements.txt
    else
      echo "No requirements.txt found. Skipping package installation."
    fi

    # Install ipykernel in the virtual environment
    echo "Installing ipykernel..."
    uv pip install ipykernel

    # Register the kernel with Jupyter
    echo "Registering kernel with Jupyter..."
    python -m ipykernel install --user --name=data-mining --display-name="Python (Data Mining)"

    echo ""
    echo "✓ Environment ready!"
    echo "  - Virtual environment: .venv"
    echo "  - Kernel name: data-mining"
  '';

  # Set environment variables
  JUPYTER_PATH = "./.venv/share/jupyter";
}