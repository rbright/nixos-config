{ pkgs, ... }:
let
  llamaCppCuda = pkgs.llama-cpp.override {
    cudaSupport = true;
  };
in
{
  services.llama-cpp = {
    # Run llama.cpp as a managed system service with CUDA acceleration.
    enable = true;
    package = llamaCppCuda;

    # Keep the API local-only for on-device workflows.
    host = "127.0.0.1";
    port = 11434;

    # Start in router mode and serve GGUF models from this directory.
    modelsDir = "/var/lib/llama-cpp/models";
  };

  systemd.services.llama-cpp.preStart = ''
    mkdir -p /var/lib/llama-cpp/models
  '';
}
