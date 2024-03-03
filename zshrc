# load custom executable functions
for function in ~/.zsh/functions/*; do
  source $function
done

# extra files in ~/.zsh/configs/pre , ~/.zsh/configs , and ~/.zsh/configs/post
# these are loaded first, second, and third, respectively.
_load_settings() {
  _dir="$2"
  if [ -d "$_dir" ]; then
    if [ -d "$_dir/pre" ]; then
      for config in "$_dir"/pre/**/*(N-.); do
        if [ ${config:e} = "zwc" ] ; then continue ; fi
        . $config
      done
    fi

    for config in "$_dir"/**/*(N-.); do
      case "$config" in
        "$_dir"/pre/*)
          :
          ;;
        "$_dir"/post/*)
          :
          ;;
        *)
          if [[ -f $config && ${config:e} != "zwc" ]]; then
            . $config
          fi
          ;;
      esac
    done

    if [ -d "$_dir/post" ]; then
      for config in "$_dir"/post/**/*(N-.); do
        if [ ${config:e} = "zwc" ] ; then continue ; fi
        . $config
      done
    fi
  fi
}
_load_settings "$HOME/.zsh/configs"

# completion
autoload -U compinit
compinit

# automatically enter directories without cd
setopt auto_cd

#
# PATH Configurations
#

# Default Unix Binaries
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

# Homebrew
# Adds Homebrew's binary directory to PATH
export PATH="/opt/homebrew/bin:$PATH"

# Node.js setup
# Setting up NVM (Node Version Manager) and adding Node to PATH
export NVM_DIR="$HOME/.nvm"
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
    . "$NVM_DIR/nvm.sh"  # Load NVM
    nvm use default  # Use the default (usually the latest) version of Node
    # Alternatively, to always use the latest installed version, uncomment the next line:
    # nvm use `nvm ls-remote --lts | tail -1 | awk '{print $1}'`
fi

# Racket
# Adding Racket binaries to PATH
export PATH="/Applications/Racket v8.10/bin:$PATH"

# Java
# Setting JAVA_HOME to the preferred version and adding Java binaries to PATH
export JAVA_HOME=$(/usr/libexec/java_home -v 21)
export PATH="$JAVA_HOME/bin:$PATH"

# Python
# Adding Python binaries to PATH, set by pipx
export PATH="$PATH:$HOME/Library/Python/3.9/bin"
export PATH="$PATH:$HOME/.local/bin"

# Setup Instructions for SF CLI Autocomplete ---
eval "$(sf autocomplete script zsh)"

# End of .zshrc configuration
