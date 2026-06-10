# Fix egrep warning
egrep() {
  echo "egrep called from: ${functrace[1]}"
  command grep -E "$@"
}
# -------------------------------------------------------------------
# SSH
# -------------------------------------------------------------------
export SSH_AUTH_SOCK=~/.bitwarden-ssh-agent.sock
# Backup original ssh
alias _ssh=/usr/bin/ssh

ssh() {
  local host="$1"
  shift

  # Resolve actual hostname from SSH config
  local realhost
  realhost=$(_ssh -G "$host" 2>/dev/null | awk '/^hostname / {print $2}')

  # Fallback to literal if resolution fails
  [[ -z "$realhost" ]] && realhost="$host"

  # Check if VPN is needed
  if [[ "$realhost" == *.unimaas.nl ]]; then
    if ! pgrep -f "openconnect.*vpn\.maastrichtuniversity\.nl" >/dev/null; then
      echo "⚠️ VPN is not active! SSH to $host ($realhost) requires the VPN."
      return 1
    fi
  fi

  # Call the original ssh
  _ssh "$host" "$@"
}

ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Add in snippets
zinit snippet OMZP::git
zinit snippet OMZP::ssh
zinit snippet OMZP::docker
zinit snippet OMZP::docker-compose
zinit snippet OMZP::dotenv
zinit snippet OMZP::fzf
zinit snippet OMZP::sudo
zinit snippet OMZP::archlinux
zinit snippet OMZP::kubectl
zinit snippet OMZP::kubectx
zinit snippet OMZP::command-not-found

# Load completions
autoload -Uz compinit && compinit
zinit cdreplay -q

#load starship
export STARSHIP_CONFIG=~/dotfiles/.config/starship/starship.toml
eval "$(starship init zsh)"

# Keybindings
bindkey '\e[H'  beginning-of-line
bindkey '\eOH'  beginning-of-line
bindkey '\e[F'  end-of-line
bindkey '\eOF'  end-of-line
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region
bindkey "^[[1;5D" backward-word
bindkey "^[[1;5C" forward-word
bindkey '\e[5~' up-line-or-history
bindkey '\e[6~' down-line-or-history

# You may need to manually set your language environment
export LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
   export EDITOR='micro'
 else
   export EDITOR='micro'
 fi

# History
HISTSIZE=10000
HISTFILE=~/repos/Datahub/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt CORRECT
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

#yazi
function yy() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# Aliases
alias ls='ls --color'
alias ll='ls -la'
alias cls='clear'
alias zshconfig="micro ~/.zshrc"
alias sshconfig="micro ~/.ssh/config"
alias nano="micro"
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -p'
alias ps='ps auxf'
alias ff='fastfetch'
alias rm='trash-put'
alias kp='kubectl get pods -o wide'
alias ks='kubectl get services -o wide'
alias kn='kubectl get nodes -o wide'
alias kd='kubectl describe'

# Shell integrations
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"

#source externals
source "$HOME/.config/zshrc/00-init"
source "$HOME/.vpn_openconnect"

# bun completions
[ -s "/home/rjuhasz/.bun/_bun" ] && source "/home/rjuhasz/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
