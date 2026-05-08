echo -n "Loading profile..."

alias l="ls -al"
alias pomodoro="cd $HOME/Dropbox/notes/pomodoro/2021_driver && vim results.md +\"vs to_do_today.md\" +\"vs activity_list.md\""
alias notes="cd $HOME/Dropbox/notes && ls -al"

alias learn="cd $HOME/Dropbox/learn && l"
alias blog="cd $HOME/Code/jasonzurita.github.io && docker compose up"

alias vimgrep="$HOME/Code/dotfiles/scripts/vimgrep.sh"

alias gitforceup="git add . && git commit --amend --no-edit && git push -f"

alias claude-home="CLAUDE_CONFIG_DIR=~/.claude-home claude"

alias sformat="swiftformat . --config .swiftformat"
# Open man page in vim (e.g., man open)
vman() {
    man $* | col -b | vim -c 'set ft=man nomod nolist' -
}

# Open iOS simulator document directory given the bundle id (e.g., iosappfolder com.company.bundleId)
alias iosappfolder='function _inspect(){ appfolder $1 };_inspect'
appfolder() {
    open `xcrun simctl get_app_container booted "$1" data` -a Finder
}

setopt share_history append_history extended_history
# Append to bash history immediately
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"
HISTSIZE=5000 # number of commands in memory for the current session
HISTFILESIZE=10000 # number of commands in the history file

export EDITOR=vim

export WORKON_HOME=$HOME/.virtualenvs

# Add Dart language server to path
export PATH="$PATH":"$HOME/.pub-cache/bin"

# Add ctags to path (for some reason the Xcode ctags was being referenced...)
export PATH="$PATH":"/usr/local/bin/ctags"

# Set Flutter Path environment variable
export PATH="/usr/local/flutter/bin:$PATH"

# Set up node version manager [nvm](https://github.com/nvm-sh/nvm#git-install)
export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && . "/opt/homebrew/opt/nvm/nvm.sh"
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && . "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

export PATH="/usr/local/opt/llvm/bin:$PATH"

# Setup homebrew for M1 (setup for hombrew-ed installed tools must come after this)
eval "$(/opt/homebrew/bin/brew shellenv)"

# Setup for [pyenv](https://github.com/pyenv/pyenv)
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
export VIRTUALENVWRAPPER_PYTHON=$HOME/.pyenv/shims/python
export PYENV_VIRTUALENVWRAPPER_PREFER_PYVENV="true"

# asdf setup (0.15+: binary in PATH via brew shellenv; add completions)
fpath=(/opt/homebrew/opt/asdf/share/zsh/site-functions $fpath)

# Setup for rbenv
eval "$(rbenv init -)"

# The next line updates PATH for the Google Cloud SDK.
if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/google-cloud-sdk/path.zsh.inc"; fi

# The next line enables shell command completion for gcloud.
if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/google-cloud-sdk/completion.zsh.inc"; fi

export PATH=~/Library/Android/sdk/tools:$PATH
export PATH=~/Library/Android/sdk/platform-tools:$PATH

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"


export PATH="$HOME/.local/bin:$PATH"

echo "done"
