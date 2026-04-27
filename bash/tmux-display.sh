# tmux DISPLAY/XAUTHORITY healing.
#
# Source from ~/.bashrc:    [ -f ~/Projects/dotfiles/bash/tmux-display.sh ] && \
#                             . ~/Projects/dotfiles/bash/tmux-display.sh
#
# Why: tmux's default update-environment behaviour records "-DISPLAY" /
# "-XAUTHORITY" (the leading "-" means "explicitly unset for new shells")
# whenever a tmux client attaches without those env vars set. Once that
# happens, every pane born from that tmux server can't talk to the X server,
# and GUI launches (subl, wmctrl, xdg-open) silently fail.
#
# (1) When this shell has DISPLAY set (started from a desktop terminal),
#     push the current values into the tmux server's global env so new panes
#     inherit them.
# (2) When this shell is INSIDE tmux, pull DISPLAY/XAUTHORITY from the tmux
#     server env. Recovers GUI access in long-lived panes after a reattach
#     from a healthy client.
#
# Idempotent. Safe in non-tmux shells (early returns).

if ! command -v tmux >/dev/null 2>&1; then
    return 0 2>/dev/null || true
fi

if [ -n "$DISPLAY" ]; then
    tmux set-environment -g DISPLAY "$DISPLAY" 2>/dev/null
    tmux set-environment -g XAUTHORITY "${XAUTHORITY:-$HOME/.Xauthority}" 2>/dev/null
fi

if [ -n "$TMUX" ]; then
    # Read the GLOBAL tmux env (-g). Session-scoped env can carry "-DISPLAY"
    # / "-XAUTHORITY" negations that shadow the global; we're explicitly
    # healing FROM that case, so reading global is the robust choice.
    eval "$(tmux show-environment -g 2>/dev/null | awk -F= '
        $1=="DISPLAY" || $1=="XAUTHORITY" { printf "export %s=%s\n", $1, $2 }')"
fi
