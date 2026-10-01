{
  lib,
  python312,
  nixosTests,
  fetchPypi,
}:
let
  pname = "open-webui";
  version = "0.6.12";
in
python312.pkgs.buildPythonApplication rec {
  inherit pname version;
  format = "wheel";

  src = fetchPypi {
    inherit pname version;
    format = "wheel";
    hash = ""; # You'll need to update this hash
  };

  pythonRelaxDeps = true;

  pythonRemoveDeps = [
    "docker"
    "pytest"
    "pytest-docker"
  ];

  dependencies =
    with python312.pkgs;
    [
      accelerate
      aiocache
      aiofiles
      aiohttp
      alembic
      anthropic
      apscheduler
      argon2-cffi
      asgiref
      async-timeout
      authlib
      azure-ai-documentintelligence
      azure-identity
      azure-storage-blob
      bcrypt
      beautifulsoup4
      black
      boto3
      chromadb
      colbert-ai
      docx2txt
      duckduckgo-search
      einops
      elasticsearch
      extract-msg
      fake-useragent
      fastapi
      faster-whisper
      firecrawl-py
      fpdf2
      ftfy
      gcp-storage-emulator
      google-api-python-client
      google-auth-httplib2
      google-auth-oauthlib
      google-cloud-storage
      google-generativeai
      googleapis-common-protos
      iso-639
      langchain
      langchain-community
      langdetect
      langfuse
      ldap3
      loguru
      markdown
      moto
      nltk
      onnxruntime
      openai
      opencv-python-headless
      openpyxl
      opensearch-py
      opentelemetry-api
      opentelemetry-sdk
      opentelemetry-exporter-otlp
      opentelemetry-instrumentation
      opentelemetry-instrumentation-fastapi
      opentelemetry-instrumentation-sqlalchemy
      opentelemetry-instrumentation-redis
      opentelemetry-instrumentation-requests
      opentelemetry-instrumentation-logging
      opentelemetry-instrumentation-httpx
      opentelemetry-instrumentation-aiohttp-client
      pandas
      passlib
      peewee
      peewee-migrate
      pgvector
      pillow
      pinecone-client
      playwright
      psutil
      psycopg2-binary
      pydub
      pyjwt
      pymdown-extensions
      pymilvus
      pymongo
      pymysql
      pypandoc
      pypdf
      python-dotenv
      python-jose
      python-multipart
      python-pptx
      python-socketio
      pytube
      pyxlsb
      qdrant-client
      rank-bm25
      rapidocr-onnxruntime
      redis
      requests
      restrictedpython
      sentence-transformers
      sentencepiece
      soundfile
      tencentcloud-sdk-python
      tiktoken
      transformers
      unstructured
      uvicorn
      validators
      xlrd
      youtube-transcript-api
    ]
    ++ moto.optional-dependencies.s3;

  pythonImportsCheck = [ "open_webui" ];

  passthru = {
    tests = {
      inherit (nixosTests) open-webui;
    };
    updateScript = ./update.sh;
  };

  meta = {
    changelog = "https://github.com/open-webui/open-webui/blob/v${version}/CHANGELOG.md";
    description = "Comprehensive suite for LLMs with a user-friendly WebUI";
    homepage = "https://github.com/open-webui/open-webui";
    license = lib.licenses.mit;
    mainProgram = "open-webui";
    maintainers = with lib.maintainers; [
      drupol
      shivaraj-bh
    ];
  };
}