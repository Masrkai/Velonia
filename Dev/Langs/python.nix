# Langs/python.nix
# `lib` was missing from the argument set before, which made lib.lowPrio an
# evaluation error. ruff / basedpyright now live in dev/registry.nix as
# standalone tools instead of inside withPackages, where an editor's LSP could
# not see them from a project's own venv.
{
  pkgs,
  lib,
  ...
}: {
  environment.systemPackages = with pkgs; [
    opencv
    ffmpeg-full
    honcho

    chromedriver
    geckodriver

    uv # package + venv manager

    (lib.lowPrio (python313.withPackages (ps:
      with ps; [
        #-> packaging / bundling
        setuptools
        python-dotenv
        pyinstaller
        pyinstaller-versionfile

        #-> debugging (adapter must share the interpreter's site-packages)
        debugpy

        #-> testing
        pytest
        pytest-cov
        pytest-aio

        # Web Scraping
        playwright
        webdriver-manager
        selenium
        curl-cffi
        beautifulsoup4
        
        #-> performance analysis
        memray

        #-> network
        aiohttp
        netutils
        requests

        #-> DBs / crypto
        pymysql
        portalocker
        cryptography

        #-> general
        geopy
        pathlib2
        screeninfo
        qrcode
        qrcode-terminal

        #-> math / stats
        numpy
        pandas
        polars

        #-> visuals
        sympy
        seaborn
        matplotx
        matplotlib

        #-> image
        pillow

        #-> AI / ML
        jax
        mcp
        # ollama
        litellm
        scikit-learn

        #-> CLI / TUI
        terminaltables

        #-> platforms
        huggingface-hub

        #-> notebooks
        marimo
        jupyter
      ])))
  ];
}
