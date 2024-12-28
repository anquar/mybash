# Path to your oh-my-bash installation.
export OSH=~/.oh-my-bash

# 设置主题
OSH_THEME="powerline"

# 启用插件
plugins=(
    git
    colored-man-pages
    pyenv
    sudo
    zoxide
)

# 如果安装了 fzf，则加载它
[ -f ~/.fzf.bash ] && source ~/.fzf.bash
# 设置 PATH
export PATH=~/.local/bin:$PATH

# 加载 oh-my-bash
source "$OSH/oh-my-bash.sh"

# 用户自定义别名和函数
alias ll='ls -la'
alias la='ls -A'
alias myip="wget -qO- https://wtfismyip.com/text"
alias l="ls -lAhrtF"
alias e="exit"

# 设置历史记录
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoreboth
shopt -s histappend

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
