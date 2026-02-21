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

    # Keep VRAM usage predictable: only one model stays loaded at a time,
    # and unload after an idle period.
    extraFlags = [
      "--models-max"
      "1"
      "--sleep-idle-seconds"
      "900"
    ];
  };

  systemd.services.llama-cpp.preStart = ''
    mkdir -p /var/lib/llama-cpp/models
  '';
}
