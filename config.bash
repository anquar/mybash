# Path to your oh-my-bash installation.
export OSH=~/.oh-my-bash

# 设置主题
OSH_THEME="powerline"

# 启用插件
plugins=(
    core
    git
    bash-autosuggestions
    bash-syntax-highlighting
)

# 如果安装了 fzf，则加载它
if [ -f ~/.oh-my-bash/custom/plugins/fzf/fzf.bash ]; then
    source ~/.oh-my-bash/custom/plugins/fzf/fzf.bash
fi

# 加载 oh-my-bash
source "$OSH/oh-my-bash.sh"

# 用户自定义别名和函数
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'

# 设置历史记录
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoreboth
shopt -s histappend