# Auto-attach to tmux for interactive SSH shells.
if [[ -n "$SSH_CONNECTION" && -z "$TMUX" && -z "$NO_AUTO_TMUX" ]]; then
  if command -v tmux >/dev/null 2>&1; then
    _ssh_tmux_host="${HOST%%.*}"
    exec tmux new-session -A -s "ssh-${_ssh_tmux_host:-remote}"
  fi
fi
