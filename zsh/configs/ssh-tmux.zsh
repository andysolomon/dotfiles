# Auto-attach to tmux for interactive SSH shells.
# Skip inside Herdr (HERDR_ENV=1): a Herdr pane is not a tmux client, so an SSH
# from one would otherwise exec tmux and nest the wrong multiplexer.
if [[ -n "$SSH_CONNECTION" && -z "$TMUX" && -z "$HERDR_ENV" && -z "$NO_AUTO_TMUX" ]]; then
  if command -v tmux >/dev/null 2>&1; then
    _ssh_tmux_host="${HOST%%.*}"
    exec tmux new-session -A -s "ssh-${_ssh_tmux_host:-remote}"
  fi
fi
