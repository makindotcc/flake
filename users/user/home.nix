{ ... }:
{
  programs = {
    git = {
      userEmail = "9150636+makindotcc@users.noreply.github.com";
      userName = "makindotcc";
    };
    ssh.includes = [
      "~/.ssh/config.extra"
    ];
  };
}
