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

# Local config
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# aliases
[[ -f ~/.aliases ]] && source ~/.aliases

# load our own completion functions
#fpath=(~/.zsh/completion $fpath)
#fpath=(~/.zsh/zsh-completions/src $fpath)

# completion
#autoload -U compinit
#compinit

#ZSH_THEME="random"

## case-insensitive (all),partial-word and then substring completion
#if [ "x$CASE_SENSITIVE" = "xtrue" ]; then
#  zstyle ':completion:*' matcher-list 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
#  unset CASE_SENSITIVE
#else
#  zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
#fi

#zstyle ':completion:*' list-colors ''

#for function in ~/.zsh/functions/*; do
#  source $function
#done

# automatically enter directories without cd
setopt AUTO_CD

# use vim as the visual editor
#export VISUAL=vim
#export EDITOR=$VISUAL

# vi mode
#bindkey -v
#bindkey "^F" vi-cmd-mode
#bindkey jj vi-cmd-mode

# use incremental search
#bindkey "^R" history-incremental-search-backward

# add some readline keys back
#bindkey "^A" beginning-of-line
#bindkey "^E" end-of-line

# handy keybindings
#bindkey "^P" history-search-backward
#bindkey "^Y" accept-and-hold
#bindkey "^N" insert-last-word
#bindkey -s "^T" "^[Isudo ^[A" # "t" for "toughguy"

# use neovim
#if type nvim > /dev/null 2>&1; then
#  alias vim='nvim'
#fi

# Highlight search results in ack.
export ACK_COLOR_MATCH='red'

# expand functions in the prompt
setopt prompt_subst

# prompt
export PS1='[${SSH_CONNECTION+"%n@%m:"}%~] '

# ignore duplicate history entries
#setopt histignoredups

# Nicer history
export HISTSIZE=100000
export HISTFILE="$HOME/.history"
export SAVEHIST=$HISTSIZE

#setopt APPEND_HISTORY # adds history
#setopt INC_APPEND_HISTORY SHARE_HISTORY  # adds history incrementally and share it across sessions
#setopt HIST_IGNORE_ALL_DUPS  # dont record dupes in history
#setopt HIST_REDUCE_BLANKS

# By @ieure; copied from https://gist.github.com/1474072
#
# It finds a file, looking up through parent directories until it finds one.
# Use it like this:
#
#   $ ls .tmux.conf
#   ls: .tmux.conf: No such file or directory
#
#   $ ls `up .tmux.conf`
#   /Users/grb/.tmux.conf
#
#   $ cat `up .tmux.conf`
#   set -g default-terminal "screen-256color"
#
#function up()
#{
#    local DIR=$PWD
#    local TARGET=$1
#    while [ ! -e $DIR/$TARGET -a $DIR != "/" ]; do
#        DIR=$(dirname $DIR)
#    done
#    test $DIR != "/" && echo $DIR/$TARGET
#  }

# look for ey config in project dirs
export EYRC=./.eyrc

# automatically pushd
#setopt auto_pushd
#export dirstacksize=5

# awesome cd movements from zshkit
#setopt AUTOCD
setopt AUTOPUSHD PUSHDMINUS PUSHDSILENT PUSHDTOHOME
setopt cdablevars

# Try to correct command line spelling
setopt CORRECT CORRECT_ALL

# Enable extended globbing
setopt EXTENDED_GLOB

# aliases
[[ -f ~/.aliases ]] && source ~/.aliases

# Local config
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# recommended by brew doctor
 export PATH='/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/local/git/bin:/Users/andrewsolomon/.bin:/Users/andrewsolomon/lynxapp/yeoman/yeoman-custom/cli/bin:/usr/local/share/npm/bin'
export PATH=$HOME/local/bin:$PATH
export NODE_PATH=/usr/local/bin/node:/usr/local/lib/node_modules:$NODE_PATH
export SSL_CERT_FILE=/usr/local/etc/openssl/certs/cacert.pem
export MONGO_PATH=/usr/local/mongodb
export PATH=$PATH:$MONGO_PATH/bin
export PATH=$PATH:/usr/local/mysql/bin
export SSL_CERT_FILE=/usr/local/etc/openssl/certs/cert.pem
export PATH=/usr/local/share/python:$PATH

#PYTHONPATH="${PYTHONPATH}:/lib/python3.4/site-packages/"
export PYTHONPATH 
. {/Users/andrewsolomon/dotfiles/vim/bundle}/powerline/bindings/zsh/powerline.zsh

# DO NOT EDIT BELOW THIS LINE
export JAVA_HOME=$(/usr/libexec/java_home)
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

#export PATH="$HOME/.bin:$PATH"
eval "$(rbenv init - zsh --no-rehash)"

#export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm

export PATH="$PATH:$HOME/.yarn/bin"

# React Native Android
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
