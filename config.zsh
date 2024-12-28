export TERM="xterm-256color"
export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.config/zsh/oh-my-zsh

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes


ZSH_THEME="powerlevel10k/powerlevel10k"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    zsh-completions
    zsh-autosuggestions
    zsh-syntax-highlighting
    history-substring-search
    systemd
    k
    z
    sudo
    git
    )

# Add to PATH to Install and run programs with "pip install --user"
export PATH=$PATH:~/.local/bin

export PATH=$PATH:~/.config/zsh/bin

autoload -U compinit && compinit -C -d ~/.cache/zsh/.zcompdump

# QuickZsh
SAVEHIST=50000 #save upto 50,000 lines in history. oh-my-zsh default is 10,000

alias myip="wget -qO- https://wtfismyip.com/text" # quickly show external ip address
alias l="ls -lAhrtF" # show all except . .. , sort by recent, / at the end of folders
alias e="exit"

# CUSTOM FUNCTIONS
function speedtest() {
    curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python3 -
}

# Find dictionary definition
dict() {
    if [ "$3" ]; then
        curl "dict://dict.org/d:$1 $2 $3"
    elif [ "$2" ]; then
        curl "dict://dict.org/d:$1 $2"
    else
        curl "dict://dict.org/d:$1"
    fi
}

# Find geo info from IP
ipgeo() {
    # Specify ip or your ip will be used
    if [ "$1" ]; then
        curl "http://api.db-ip.com/v2/free/$1"
    else
        curl "http://api.db-ip.com/v2/free/$(myip)"
    fi
    # 换行
    echo ""
}
