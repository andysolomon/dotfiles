# Auto-attach interactive SSH shells to the host's Herdr session.
# Skip inside an existing Herdr pane (HERDR_ENV=1) so we do not exec a nested
# client. NO_AUTO_HERDR=1 and NO_AUTO_TMUX=1 are escape hatches (plain remote shell).
#
# `herdr` often lives in ~/.local/bin, which is appended later in zshrc, so
# look there explicitly. If Herdr is missing, keep a normal SSH shell.
if [[ -o interactive && -n "$SSH_CONNECTION" && -z "$TMUX" && -z "$HERDR_ENV" && -z "$NO_AUTO_TMUX" && -z "$NO_AUTO_HERDR" ]]; then
  _ssh_herdr=""
  if command -v herdr >/dev/null 2>&1; then
    _ssh_herdr="$(command -v herdr)"
  elif [[ -x "$HOME/.local/bin/herdr" ]]; then
    _ssh_herdr="$HOME/.local/bin/herdr"
  fi

  if [[ -n "$_ssh_herdr" ]]; then
    exec "$_ssh_herdr"
  else
    print -u2 "ssh-herdr: herdr not found; starting a plain shell (install herdr, or set NO_AUTO_HERDR=1)."
  fi
fi
