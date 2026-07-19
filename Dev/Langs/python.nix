{ pkgs, ... }:

{

   environment.systemPackages = with pkgs; [

    opencv
    # llama-cpp
    ffmpeg-full

    honcho

    chromedriver
    geckodriver

    (lib.lowPrio (python313.withPackages (ps: with ps; [

        #-> Basics for IDEs
        ruff          # linter and code formatter
        debugpy       # Debugger
        basedpyright  # LSP server

        #-> Basics for package installation / bundeling
        uv                       # Package Manager & virtual environment manager (replaces pip while being better at everything)
        setuptools               # Utilities to facilitate the installation of Python packages
        python-dotenv            # Add .env support to your apps
        pyinstaller              # Tool to bundle a python application with dependencies into a single package
        pyinstaller-versionfile  # Create a windows version-file from a simple YAML file that can be used by PyInstaller

        #-> testing
        pytest
        pytest-cov
        pytest-aio
        selenium

        #-> Performance Analysis
        memray

        #-> Network libs
        aiohttp
        netutils
        requests

        #-> DBs / cryptography
        sqlite
        pymysql
        portalocker
        cryptography

        #-> General libs
        geopy
        pathlib2
        screeninfo
        qrcode
        qrcode-terminal

        #-> General Math/Statistics libs
        numpy
        pandas
        polars

        #-> Visuals libs
        seaborn
        matplotx
        matplotlib

        #-> Image processing
        pillow

        #-> AI/ML - NLP
        jax
        ollama
        litellm
        # torch

        #-> GUIs
        # pyqt6
        # pyside6
        # pyqt6-sip
        # pyqt6-charts
        # pyqt6-webengine
        # raylib-python-cffi

        #-> CLI/TUI
        terminaltables

        #-> Platforms
        huggingface-hub

        #-> Notebooks
        marimo        # Jupyter Notebook killer (Thankfully this was a rough time using jupyter notebooks.. shesh)

          # #-> Juniper/jupter
          # notebook
          # nbformat
          # ipynbname
          # ipywidgets

          # #-> IpyKernal
          # ipython
          # ipykernel
          # ipython-sql
          # ipython-genutils
        ]
      )
    )
    )

   ];
}
