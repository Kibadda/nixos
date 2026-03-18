{
  config,
  secrets,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.kibadda;
in
{
  options = {
    kibadda.git = {
      settings = lib.mkOption {
        type = lib.types.attrs;
        default = { };
      };

      includes = lib.mkOption {
        type = lib.types.listOf (lib.types.attrsOf lib.types.anything);
        default = [ ];
      };
    };
  };

  config = {
    programs.git = {
      enable = true;
      settings = lib.recursiveUpdate {
        user = {
          name = secrets.base.name;
          email = secrets.base.email;
        };

        alias = {
          nah = "!f(){ git reset --hard; git clean -df; if [ -d \".git/rebase-apply\" ] || [ -d \".git/rebase-merge\" ]; then git rebase --abort; fi; }; f";
          forget = "!git fetch -p && git branch -vv | awk '/: gone]/{print $1}' | xargs git branch -D";
          forgetlist = "!git fetch -p && git branch -vv | awk '/: gone]/{print $1}'";
          uncommit = "reset --soft HEAD~1";
          lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --";
          fixup = "!git commit --fixup $(git rev-parse HEAD)";
          filter-commits = "!sh -c 'git log --pretty=format:\"%h - %an: %s\" $1 | fzf --no-sort | cut -d \" \" -f1 ' -";
          fixup-to = "!git commit --fixup=$(git filter-commits)";
          unlock = "!git-crypt unlock";
          lock = "!git-crypt lock";
          dirty = "!gitdirty";
        };

        pull.rebase = true;
        init.defaultBranch = "main";
      } cfg.git.settings;

      includes = cfg.git.includes;

      signing = {
        key = secrets.base.keyid;
        signByDefault = true;
      };
    };

    home.packages = [
      pkgs.git-crypt
      pkgs.kibadda.gitdirty
    ];
  };
}
