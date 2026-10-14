# load custom executable functions
for function in ~/.zsh/functions/*; do
  source $function
done

# extra files in ~/.zsh/configs/pre , ~/.zsh/configs , and ~/.zsh/configs/post
# these are loaded first, second, and third, respectively.
_load_settings() {
  _dir="$1"
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

# Set REPLY to the bin directory of nvm's default Node by reading nvm's alias
# files, without running nvm. Follows alias chains (default -> lts/* ->
# lts/krypton -> v24.11.0) and takes the newest installed match for a partial
# version (24 -> v24.18.0). Fails for anything else, such as `system`.
_nvm_default_bin() {
    local spec=default
    local -a matches
    repeat 5; do
        [[ -f "$NVM_DIR/alias/$spec" ]] || break
        spec="$(<"$NVM_DIR/alias/$spec")"
    done
    case "$spec" in
        node|stable) matches=("$NVM_DIR"/versions/node/v*(N/nOn)) ;;
        v[0-9]*|[0-9]*) matches=("$NVM_DIR"/versions/node/v${spec#v}(|.*)(N/nOn)) ;;
    esac
    (( $#matches )) || return 1
    REPLY="$matches[1]/bin"
    [[ -x "$REPLY/node" ]]
}

if [[ -s "$NVM_DIR/nvm.sh" ]]; then
    # Startup time matters beyond comfort: T3 Code drops the shell PATH if
    # `zsh -ilc` takes over 5s, and a startup that is fine warm can pass that
    # right after boot. Sourcing nvm.sh and running `nvm use default` cost
    # ~1.5s, so put the default Node on PATH directly and load nvm itself the
    # first time it is called.
    if _nvm_default_bin; then
        path=(${path:#$NVM_DIR/versions/node/*/bin})  # a Node inherited from the parent shell
        export PATH="$REPLY:$PATH"
        export NVM_BIN="$REPLY" NVM_INC="${REPLY:h}/include/node"
        nvm() {
            unfunction nvm
            . "$NVM_DIR/nvm.sh" --no-use
            nvm "$@"
        }
    else
        # --no-use: nvm.sh would otherwise run its own `nvm use` on load and
        # the explicit one below would repeat it (~1s each).
        . "$NVM_DIR/nvm.sh" --no-use
        nvm use default --silent
    fi
fi
unfunction _nvm_default_bin

# Racket
# Adding Racket binaries to PATH
export PATH="/Applications/Racket v8.10/bin:$PATH"

# Java
# Setting JAVA_HOME to the preferred version and adding Java binaries to PATH.
# Guard on availability so shells don't error when JDK 21 isn't installed.
if /usr/libexec/java_home -v 21 >/dev/null 2>&1; then
  export JAVA_HOME="$(/usr/libexec/java_home -v 21)"
  export PATH="$JAVA_HOME/bin:$PATH"
fi

# Python
# Adding Python binaries to PATH, set by pipx
export PATH="$PATH:$HOME/Library/Python/3.9/bin"
export PATH="$PATH:$HOME/.local/bin"

# Machine-specific overrides (secrets, tool completions, per-host tweaks).
# Kept out of the repo; sourced last so it can override anything above.
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# End of .zshrc configuration
