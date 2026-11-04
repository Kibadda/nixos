{
  perSystem =
    {
      pkgs,
      ...
    }:
    {
      packages.gitdirty = pkgs.writeShellApplication {
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
          MAX_ERROR_LINES=5

          errfile=$(mktemp)
          trap 'rm -f "$errfile"' EXIT

          # Run git in a repo, collecting stderr in $errfile so a failure can be
          # reported for that directory instead of aborting the whole run.
          git_in() {
            local repo=$1
            shift
            git -C "$repo" "$@" 2>>"$errfile"
          }

          while IFS= read -r -d "" gitdir; do
            repo=$(dirname "$gitdir")
            : >"$errfile"

            ahead=0
            dirty=0
            repo_error=0
            branch="unknown"

            # HEAD: symbolic-ref works on a normal (even unborn) branch,
            # rev-parse covers detached HEADs. If neither works the repo is
            # unreadable, so don't ask git anything else and report the failure.
            if symbolic=$(git_in "$repo" symbolic-ref --short HEAD) && [ -n "$symbolic" ]; then
              branch=$symbolic
              if upstream=$(git_in "$repo" rev-parse --abbrev-ref --symbolic-full-name "@{u}") && [ -n "$upstream" ]; then
                ahead=$(git_in "$repo" rev-list --count "$upstream"..HEAD) || ahead=0
              fi
            elif detached=$(git_in "$repo" rev-parse --verify --quiet --short HEAD) && [ -n "$detached" ]; then
              branch=$detached
            else
              repo_error=1
            fi

            if [ "$repo_error" -eq 0 ]; then
              # git diff exits 1 when there are differences and >1 on an error.
              status=0
              git_in "$repo" diff --quiet || status=$?
              if [ "$status" -eq 1 ]; then
                dirty=1
              elif [ "$status" -gt 1 ]; then
                repo_error=1
              fi

              status=0
              git_in "$repo" diff --cached --quiet || status=$?
              if [ "$status" -eq 1 ]; then
                dirty=1
              elif [ "$status" -gt 1 ]; then
                repo_error=1
              fi
            fi

            printf "%b%-40s%b  (%s)\n" "$BLUE" "$repo" "$RESET" "$branch"

            if [ "$repo_error" -eq 1 ]; then
              printf "  %b error: git failed in this directory %b\n" "$RED" "$RESET"
              if [ -s "$errfile" ]; then
                shown=0
                skipped=0
                previous=""
                while IFS= read -r line; do
                  # git repeats the same fatal message for every invocation
                  if [ "$line" = "$previous" ] || [ -z "$line" ]; then
                    continue
                  fi
                  previous=$line
                  if [ "$shown" -lt "$MAX_ERROR_LINES" ]; then
                    printf "  %b%s%b\n" "$RED" "$line" "$RESET"
                    shown=$((shown + 1))
                  else
                    skipped=$((skipped + 1))
                  fi
                done <"$errfile"
                if [ "$skipped" -gt 0 ]; then
                  printf "  %b... (%s more line(s))%b\n" "$RED" "$skipped" "$RESET"
                fi
              fi
            elif [ "$dirty" -eq 1 ]; then
              printf "  %b uncommitted changes %b\n" "$RED" "$RESET"
            else
              printf "  %b clean %b\n" "$GREEN" "$RESET"
            fi

            if [ "$repo_error" -eq 0 ] && [ "$ahead" -gt 0 ]; then
              printf "  %b %s unpushed commit(s) %b\n" "$YELLOW" "$ahead" "$RESET"
            fi
          done < <(find . -type d -name ".git" -prune -print0)
        '';
      };
    };
}
