{ pkgs, ... }: {
  home = {
    sessionVariables = {
      BROWSER = "google-chrome-stable";
    };

    packages = with pkgs; [
      google-chrome
    ];
  };
}
