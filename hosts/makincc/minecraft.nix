{ pkgs, ... }:
{
  services.minecraft-server = {
    enable = true;
    eula = true;
    package = pkgs.papermcServers.papermc-1_21_8;
    openFirewall = true;
    declarative = true;
    serverProperties = {
      server-port = 25565;
      difficulty = 0;
      gamemode = 0;
      max-players = 5;
      motd = "NixOS Minecraft server!";
      white-list = false;
    };
    jvmOpts = "-Xms2G -Xmx4G";
  };
}
