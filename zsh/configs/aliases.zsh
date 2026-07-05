# Load command aliases from the top-level `aliases` file (symlinked to ~/.aliases
# by install.sh). Nothing else sources it, so without this the alias definitions
# — including the vim/vi -> nvim routing — never take effect.
[[ -f ~/.aliases ]] && source ~/.aliases
