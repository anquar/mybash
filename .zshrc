################# DO NOT MODIFY THIS FILE ###################
#### PLACE YOUR CONFIGS IN ~/.config/muyz/zshrc FOLDER ######
#############################################################

# Your original .zshrc is backed up at ~/.zshrc-backup-%y-%m-%d


# Load zsh configurations
source "$HOME/.config/muyz/config.zsh"

# Place all of your personal configurations over there
ZSH_CONFIGS_DIR="$HOME/.config/muyz/zshrc"

if [ "$(ls -A $ZSH_CONFIGS_DIR)" ]; then
    for file in "$ZSH_CONFIGS_DIR"/*; do
        source "$file"
    done
fi

source $ZSH/oh-my-zsh.sh


# Configs that can only work after "source $ZSH/oh-my-zsh.sh", such as Aliases that depend oh-my-zsh plugins

# Now source fzf.zsh , otherwise Ctr+r is overwritten by ohmyzsh
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_OPS="--extended"

alias k="k -h" # show human readable file sizes, in kb, mb etc
