############################################
#
#             Theme stuff
#
############################################

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Theme to load
ZSH_THEME="powerlevel10k/powerlevel10k"

# If it exists, run the contents of ~/.p10k.zsh (p10k theme settings)
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

############################################
#
#              Environment
#
############################################

# Path to oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Oh my zsh type shit frfr
source $ZSH/oh-my-zsh.sh

# Plugins
plugins=(git)

# Set default editor to nvim
export EDITOR='nvim'

# Set default git editor
export GIT_EDITOR='nvim'

# Homebrew environment variables
eval "$(/opt/homebrew/bin/brew shellenv)"

# Add julia-installed binaries to PATH 
export PATH="$HOME/.juliaup/bin:$PATH"

# Add cargo-installed binaries to PATH
export PATH="$HOME/.cargo/bin:$PATH"

# Pull /usr/bin to front (brew fucks with this)
export PATH="/usr/bin:$PATH"

# Set SSH authentication socket to 1Password provision
export SSH_AUTH_SOCK="$HOME/.1password/agent.sock"

# Set up pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# Pyenv virtual environments plugin
eval "$(pyenv virtualenv-init -)"

############################################
#
#            	Shortcuts 
#
############################################

# Utility environment variables
export TEMPLATES="$HOME/.templates"

# Git aliases
alias ginit="git init ."
alias ga="git add"
alias gc="git commit"
alias gp="git push"

# Use exa for listing
alias exa="exa -lahTFR --group-directories-first --level=1 --no-user"

# Nicer ytop theme
alias ytop="ytop -as -c monokai -I 1/4"

# File/project watching
alias watch="watchexec"

############################################
#
#              Syntax Highlighting 
#
############################################

# If this fails, brew install zsh-syntax-highlighting
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# uv uses a script in .local to add itself to PATH for whatever fucking reason
. "$HOME/.local/bin/env"
