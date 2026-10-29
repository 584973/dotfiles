# Shared shell shortcuts for zsh, bash and Pi's bash tool.
# Functions only: no interactive setup, no output, safe to source repeatedly.
# Loaded from ~/.zshrc, ~/.bashrc and Pi's shellCommandPrefix setting.
#
#   repo [<file>|<number>|flags]  open the repository (or file/PR/issue) on GitHub
#   pr   [<number>]               open the pull request for the current branch
#   repo-pr                       open the current branch on GitHub to create a pull request
#   mtest <class> [Maven options]  run a test class from the current Maven directory
#
# repo passes arguments straight to 'gh browse', so these work too:
#   repo --actions | --releases | --wiki | --settings | --projects
#   repo --blame README.md         blame view for a file
#   repo --commit=<ref>            tree at a ref (the '=' is required)
#   repo <sha>                     commit page
#   repo 12                        issue or PR #12
#   repo -R owner/repo             another repository
#   repo -n <anything>             print the URL instead of opening it
#
# Note: 'pr' shadows /usr/bin/pr (coreutils); use 'command pr' for the original.

# gh opens the browser with xdg-open and waits for it to exit. On Linux that
# blocks the terminal until the browser closes, and Ctrl-C kills the browser
# (both are in the foreground process group). Hand gh a detached opener instead:
# 'setsid -f' forks xdg-open into its own session and returns immediately, so the
# prompt comes back at once and the browser outlives the terminal. gh splits
# GH_BROWSER on spaces, so a multi-word opener works. macOS 'open' already hands
# the URL to launchd, so nothing is needed there.
if command -v setsid >/dev/null 2>&1 && command -v xdg-open >/dev/null 2>&1; then
  _gh_browser="setsid -f xdg-open"
else
  _gh_browser=""
fi

_gh() {
  GH_BROWSER="${GH_BROWSER:-$_gh_browser}" gh "$@"
}

_gh_branch() {
  local branch
  if ! branch=$(git symbolic-ref --quiet --short HEAD 2>/dev/null); then
    printf '%s\n' "gh: not on a branch (detached HEAD)" >&2
    return 1
  fi
  printf '%s\n' "$branch"
}

mtest() {
  case "${1-}" in
    ''|-*)
      printf '%s\n' 'usage: mtest <class> [Maven options...]' >&2
      return 2
      ;;
  esac

  local test_class runner
  test_class=$1
  runner=mvn
  shift
  if [ -f ./mvnw ]; then
    runner=./mvnw
  fi
  "$runner" "-Dtest=$test_class" test "$@"
}

repo() {
  _gh browse "$@"
}

pr() {
  if [ "$#" -gt 0 ]; then
    _gh pr view --web "$@"
    return
  fi
  if ! _gh pr view --web; then
    printf '%s\n' "hint: 'repo-pr' opens the current branch on GitHub to create a pull request" >&2
    return 1
  fi
}

repo-pr() {
  local branch remote
  branch=$(_gh_branch) || return 1
  remote=$(git config --get "branch.$branch.remote") \
    || remote=$(git config --get remote.pushDefault) \
    || remote=origin
  if ! git ls-remote --exit-code --heads --quiet "$remote" "$branch" >/dev/null 2>&1; then
    printf 'repo-pr: branch "%s" is not on "%s" yet - push it with: git push -u %s %s\n' \
      "$branch" "$remote" "$remote" "$branch" >&2
    return 1
  fi
  _gh pr create --web --head "$branch"
}
