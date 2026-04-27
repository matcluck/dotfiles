#!/usr/bin/env bash
# Status-bar segments for tmux. Called from status-left/status-right.
# Each subcommand prints a single short string (no trailing newline preferred).

set -u

cmd="${1:-}"

case "$cmd" in
  env)
    # Current deploy/work env. Reads ~/.config/tmux/env – populate it however
    # you like (manual `echo prod > ~/.config/tmux/env`, a symlink to whatever
    # tool you use to switch contexts, a shell hook, etc.).
    e=$(cat ~/.config/tmux/env 2>/dev/null || echo none)
    printf '%s' "$e"
    ;;

  env-hex)
    # Returns a hex colour based on env – catppuccin red for prod, green for dev.
    e=$(cat ~/.config/tmux/env 2>/dev/null || echo none)
    case "$e" in
      prod) printf '#f38ba8' ;;
      dev)  printf '#a6e3a1' ;;
      *)    printf '#f9e2af' ;;
    esac
    ;;

  git)
    # Branch + dirty marker for the given path.
    path="${2:-$PWD}"
    [[ -d "$path" ]] || exit 0
    branch=$(git -C "$path" symbolic-ref --short HEAD 2>/dev/null) || exit 0
    dirty=$(git -C "$path" status --porcelain 2>/dev/null | head -n1)
    if [[ -n "$dirty" ]]; then
      printf '%s*' "$branch"
    else
      printf '%s' "$branch"
    fi
    ;;

  wg)
    # WireGuard tunnel state – only prints if a wg interface exists.
    out=$(ip -br link show type wireguard 2>/dev/null)
    [[ -z "$out" ]] && exit 0
    if grep -q ' UP ' <<<"$out"; then
      printf 'wg↑'
    else
      printf 'wg↓'
    fi
    ;;

  waiting)
    # Count windows whose name carries the "needs input" emoji from the
    # Claude rename hook. Scoped to the session passed in $2 so multi-session
    # setups don't bleed counts across sessions. Zero prints nothing.
    session="${2:-}"
    n=$(tmux list-windows ${session:+-t "$session"} -F '#W' 2>/dev/null | grep -c '💬' || true)
    [[ "${n:-0}" -gt 0 ]] && printf '💬 %s waiting' "$n"
    ;;

  working)
    session="${2:-}"
    n=$(tmux list-windows ${session:+-t "$session"} -F '#W' 2>/dev/null | grep -c '⚡' || true)
    [[ "${n:-0}" -gt 0 ]] && printf '⚡ %s' "$n"
    ;;
esac
