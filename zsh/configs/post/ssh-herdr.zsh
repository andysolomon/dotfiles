# Auto-attach interactive SSH shells to the host's Herdr session.
# Skip inside an existing Herdr pane (HERDR_ENV=1) so we do not exec a nested
# client. NO_AUTO_TMUX=1 remains the escape hatch (plain remote shell).
#
# `herdr` often lives in ~/.local/bin, which is appended later in zshrc, so
# look there explicitly. Fall back to tmux when Herdr is not installed.
if [[ -o interactive && -n "$SSH_CONNECTION" && -z "$TMUX" && -z "$HERDR_ENV" && -z "$NO_AUTO_TMUX" ]]; then
  _ssh_herdr=""
  if command -v herdr >/dev/null 2>&1; then
    _ssh_herdr="$(command -v herdr)"
  elif [[ -x "$HOME/.local/bin/herdr" ]]; then
    _ssh_herdr="$HOME/.local/bin/herdr"
  fi

  if [[ -n "$_ssh_herdr" ]]; then
    exec "$_ssh_herdr"
  elif command -v tmux >/dev/null 2>&1; then
    _ssh_tmux_host="${HOST%%.*}"
    exec tmux new-session -A -s "ssh-${_ssh_tmux_host:-remote}"
  fi
fi
