{ ... }:
{
  programs = {
    git.settings.user = {
      email = "9150636+makindotcc@users.noreply.github.com";
      name = "makindotcc";
    };
    ssh.includes = [
      "~/.ssh/config.extra"
    ];
  };
}
