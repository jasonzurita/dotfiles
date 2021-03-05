echo -n "Loading profile..."

alias l="ls -al"
alias pomodoro="cd $HOME/Dropbox/notes/pomodoro/2021 && vim results.md +\"vs to_do_today.md\" +\"vs activity_list.md\""
alias notes="cd $HOME/Dropbox/notes && ls -al"

alias learn="cd $HOME/Dropbox/learn && l"
alias blog="cd $HOME/Work/other/jasonzurita.github.io && l"

alias vimgrep="$HOME/Work/scripts/vimgrep.sh"

alias gitforceup="git add . && git commit --amend --no-edit && git push -f"

# Open man page in vim (e.g., man open)
vman() {
    man $* | col -b | vim -c 'set ft=man nomod nolist' -
}

shopt -s histappend # make sure to append to history file
# Append to bash history immediately
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"
HISTSIZE=5000 # number of commands in memory for the current session
HISTFILESIZE=10000 # number of commands in the history file

export EDITOR=vim

export PATH="/usr/local/opt/python/libexec/bin:$PATH"

# Add Dart language server to path
export PATH="$PATH":"$HOME/.pub-cache/bin"

# Add ctags to path (for some reason the Xcode ctags was being referenced...)
export PATH="$PATH":"/usr/local/bin/ctags"

export PATH="$(pyenv root)/shims:/usr/local/bin:/usr/bin:/bin"

# Set Flutter Path environment variable
export PATH="/usr/local/flutter/bin:$PATH"

# Setup go
export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:$(go env GOPATH)/bin

# Set up node version manager (nvm - https://github.com/nvm-sh/nvm#git-install)
export NVM_DIR="$HOME/.nvm"
  [ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && . "/usr/local/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

export PATH="/usr/local/opt/llvm/bin:$PATH"

export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

echo "done"
