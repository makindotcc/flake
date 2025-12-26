{ pkgs, config, ... }:
let
  openRgbPackage = pkgs.openrgb.overrideAttrs (old: {
    src = pkgs.fetchFromGitLab {
      owner = "CalcProgrammer1";
      repo = "OpenRGB";
      rev = "release_candidate_1.0rc1";
      sha256 = "sha256-jKAKdja2Q8FldgnRqOdFSnr1XHCC8eC6WeIUv83e7x4=";
    };

    patches = [ ];

    postPatch = ''
      patchShebangs scripts/build-udev-rules.sh
      substituteInPlace scripts/build-udev-rules.sh \
        --replace-fail /usr/bin/env "${pkgs.coreutils}/bin/env"
    '';
  });

  defaultProfilePath = "${config.users.users.user.home}/.config/OpenRGB/essa";
in
{
  environment.systemPackages = [ pkgs.i2c-tools ];

  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd";
    startupProfile = defaultProfilePath;
    package = openRgbPackage;
  };

  environment.etc."systemd/system-sleep/openrgb-hook" = {
    text = ''
      #!/bin/sh
      case "$1" in
        pre)
          ${openRgbPackage}/bin/openrgb --mode off
          ;;
        post)
          ${openRgbPackage}/bin/openrgb --profile ${defaultProfilePath}
          ;;
      esac
    '';
    mode = "0755";
  };

  impermanence.normalUsers.directories = [ ".config/OpenRGB" ];
  environment.persistence.${config.impermanence.dir}.directories = [
    "/var/lib/OpenRGB/"
  ];
}
