{...}: {
  services.hermes-agent = {
    enable = true;
    environmentFiles = ["/run/secrets/hermes-agent-env"];
    addToSystemPackages = true;

    extraDependencyGroups = ["messaging"];

    createUser = false;
    user = "root";
    group = "root";

    settings = {
      model = {
        default = "mistral-large-latest";
        provider = "custom";
        base_url = "https://api.mistral.ai/v1";
        api_key = "\${MISTRAL_API_KEY}";
      };
    };
  };
}
