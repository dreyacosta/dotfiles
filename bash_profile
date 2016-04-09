# Load ~/.extra, ~/.bash_prompt, ~/.exports, ~/.aliases and ~/.functions
# ~/.extra can be used for settings you don’t want to commit
for file in ~/.{extra,bash_prompt,exports,aliases,functions}; do
  [ -r "$file" ] && source "$file"
done
unset file

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob

# Bash completion
if [ -f $(brew --prefix)/etc/bash_completion ]; then
  . $(brew --prefix)/etc/bash_completion
fi

# Prefer US English and use UTF-8
export LC_ALL="en_US.UTF-8"
export LANG="en_US"

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2)" scp sftp ssh

# Add tab completion for `defaults read|write NSGlobalDomain`
# You could just use `-g` instead, but I like being explicit
complete -W "NSGlobalDomain" defaults

# NVM
export NVM_DIR=~/.nvm
. $(brew --prefix nvm)/nvm.sh

# Homebrew
export PATH="/usr/local/sbin:$PATH"

# Docker machine
if [ $(docker-machine status) = "Running" ]; then
  eval $(docker-machine env)
fi

# Check .nvmrc file
function enter_directory() {
  if [ "$PWD" != "$PREV_PWD" ]; then
    PREV_PWD="$PWD"
    if [[ -f .nvmrc && -r .nvmrc ]]; then
      nvm use
    fi
  fi
}

export PROMPT_COMMAND=enter_directory
