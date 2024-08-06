{ config, meta, ... }: let
  cfg = config.kibadda;
in {
  programs.git = {
    enable = true;
    userName = meta.name;
    userEmail = cfg.git.email;
    signing = {
      key = meta.keyid;
      # enable after renewing yubikey subkeys
      signByDefault = false;
    };
    extraConfig = {
      pull.rebase = true;
      init.defaultBranch = "main";
    };
    aliases = {
      nah = "!f(){ git reset --hard; git clean -df; if [ -d \".git/rebase-apply\" ] || [ -d \".git/rebase-merge\" ]; then git rebase --abort; fi; }; f";
      forget = "!git fetch -p && git branch -vv | awk '/: gone]/{print $1}' | xargs git branch -D";
      forgetlist = "!git fetch -p && git branch -vv | awk '/: gone]/{print $1}'";
      uncommit = "reset --soft HEAD~1";
      lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --";
      fixup = "!git commit --fixup $(git rev-parse HEAD)";
      filter-commits = "!sh -c 'git log --pretty=format:\"%h - %an: %s\" $1 | fzf --no-sort | cut -d \" \" -f1 ' -";
      fixup-to = "!git commit --fixup=$(git filter-commits)";
    };
    includes = cfg.git.includes;
  };
}
