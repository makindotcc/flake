{ inputs, ... }:
{
  imports = [
    inputs.buzkaaclicker-backend.nixosModules.default
  ];

  services.buzkaaclicker-backend = {
    enable = true;
    clickerVersion = 16;
  };
}
