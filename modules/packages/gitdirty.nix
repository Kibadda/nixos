{
  pkgs,
}:
pkgs.writeShellApplication {
  name = "gitdirty";
  runtimeInputs = [
    pkgs.git
    pkgs.findutils
    pkgs.coreutils
  ];
  text = ''
    RED="\033[31m"
    GREEN="\033[32m"
    YELLOW="\033[33m"
    BLUE="\033[34m"
    RESET="\033[0m"

    find . -type d -name ".git" -prune | while read -r gitdir; do
      repo=$(dirname "$gitdir")

      ahead=0
      if git -C "$repo" symbolic-ref -q HEAD >/dev/null; then
        branch=$(git -C "$repo" symbolic-ref --short HEAD)
        upstream=$(git -C "$repo" rev-parse --abbrev-ref --symbolic-full-name "@{u}" 2>/dev/null)
        if [ -n "$upstream" ]; then
          ahead=$(git -C "$repo" rev-list --count "$upstream"..HEAD 2>/dev/null)
        fi
      else
        branch=$(git -C "$repo" rev-parse --short HEAD)
      fi

      dirty=0
      git -C "$repo" diff --quiet || dirty=1
      git -C "$repo" diff --cached --quiet || dirty=1

      printf "%b%-40s%b  (%s)\n" "$BLUE" "$repo" "$RESET" "$branch"

      if [ "$dirty" -eq 1 ]; then
        echo -e "  $RED uncommited changes $RESET"
      else
        echo -e "  $GREEN clean $RESET"
      fi

      if [ "$ahead" -gt 0 ]; then
        echo -e "  $YELLOW $ahead unpushed commit(s) $RESET"
      fi
    done
  '';
}
