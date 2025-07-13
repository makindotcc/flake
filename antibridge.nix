{
  self,
  inputs,
  config,
  ...
}:
{
  imports = [
    inputs.antibridge.nixosModules.default
  ];

  services.antibridge = {
    enable = true;
    secretsFile = config.age.secrets.antibridge.path;
    queries = [

    ];
  };

  age.secrets.antibridge.file = self + /secrets/antibridge.age;
}
