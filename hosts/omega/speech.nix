_: {
  programs.sotto.enable = true;

  services.rivaNim = {
    enable = true;
    containerName = "riva-nim";
    image = "nvcr.io/nim/nvidia/parakeet-1-1b-ctc-en-us:latest";
    tagsSelector = "name=parakeet-1-1b-ctc-en-us,mode=all";
    envFile = "/home/rbright/.config/riva/riva-nim.env";
    cacheDir = "/var/lib/riva-nim/cache";
    modelsDir = "/var/lib/riva-nim/models";
    runtimeUid = 1000;
    runtimeGid = 1000;
    listenAddress = "127.0.0.1";
    grpcPort = 50051;
    httpPort = 9000;
    healthPath = "/v1/health/ready";
  };
}
