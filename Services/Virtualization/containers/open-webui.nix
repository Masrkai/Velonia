{ tz }:
{
  image = "ghcr.io/open-webui/open-webui:ollama";

  environment = {
    "TZ" = tz;

    "USE_CUDA_DOCKER" = "True";

    "OLLAMA_BASE_URL" = "http://127.0.0.1:11434";
    "OLLAMA_API_BASE_URL" = "http://127.0.0.1:11434/api";

    "DO_NOT_TRACK" = "True";
      "SCARF_NO_ANALYTICS" = "True";
      "ANONYMIZED_TELEMETRY" = "False";
      "WEBUI_SESSION_COOKIE_SECURE" = "True";
      "WEBUI_SESSION_COOKIE_SAME_SITE" = "strict";

    "WHISPER_MODEL_AUTO_UPDATE" = "False";
    "RAG_EMBEDDING_MODEL_AUTO_UPDATE" = "False";
    "RAG_RERANKING_MODEL_AUTO_UPDATE" = "False";

        "ENABLE_RAG_WEB_SEARCH" = "True";
        "ENABLE_RAG_LOCAL_WEB_FETCH" = "True";
          "ENABLE_RAG_WEB_LOADER_SSL_VERIFICATION" = "True";

          "RAG_WEB_SEARCH_ENGINE" = "searxng";
                "SEARXNG_QUERY_URL" = "http://127.0.0.1:8880/search?q=<query>&format=json&language=en&safesearch=0";

          "RAG_WEB_SEARCH_RESULT_COUNT" = "5";
          "RAG_WEB_SEARCH_CONCURRENT_REQUESTS" = "15";

    "ENABLE_RETRIEVAL_QUERY_GENERATION" = "True";
    #  "RAG_EMBEDDING_MODEL" = "granite-embedding:30m";
    #  "RAG_RERANKING_MODEL" = "";

    "CONTENT_EXTRACTION_ENGINE" = "tika";
    "TIKA_SERVER_URL" = "http://localhost:9998";

    "PDF_EXTRACT_IMAGES" = "True";

    "RAG_TOP_K" = "5";
    # "RAG_TEMPLATE" = "
    # ";

    #! NONSENSE IN MY HUMBLE OPINION
    "ENABLE_OPENAI_API" = "False";
    "ENABLE_MESSAGE_RATING" = "False";
    "ENABLE_EVALUATION_ARENA_MODELS" = "False";
    "ENABLE_AUTOCOMPLETE_GENERATION" = "False";
  };

  volumes = [
    "${builtins.getEnv "HOME"}/open-webui/data:/app/backend/data"
  ];

  ports = ["127.0.0.1:3000:8080"];

  extraOptions = [
    "--name=open-webui"
    "--hostname=open-webui"
    "--add-host=host.containers.internal:host-gateway"

    # "--gpus=all"
    "--pull=never"
    "--network=host"
  ];
}