{ pkgs, ... }:
{
  environment.systemPackages = [
    (pkgs.ollama.override {
      acceleration = "cuda";
    })
  ];

  impermanence.normalUsers.directories = [ ".ollama" ];
}
