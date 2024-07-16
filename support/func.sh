#!/bin/bash

[ $(type -t LOGI) == "function" ] || source ./base.sh

# 检查系统类型
function check_os() {
    local release=""
    # 从 /etc/os-release 文件中读取 ID_LIKE 字段的值
    local id_like=$(grep '^ID_LIKE=' /etc/os-release | cut -d'=' -f2)

    # 如果存在 ID_LIKE 字段，则返回第一个类型
    if [ -n "$id_like" ]; then
        release=$(echo "$id_like" | cut -d' ' -f1)
    else
        # 否则，从 ID 字段获取系统类型
        release=$(grep '^ID=' /etc/os-release | cut -d'=' -f2)
    fi
    echo $release | tr -d '"'
}

# 检查系统类型
function check_package_manager() {
    local package_manager=""
    # 检查 apt 是否存在
    if [ -x "$(command -v apt)" ]; then
        package_manager="apt"
    elif [ -x "$(command -v yum)" ]; then
        # 检查 yum 是否存在
        package_manager="yum"
    else
        package_manager="unknown"
    fi
    echo $package_manager
}

# 检查网络连接情况
# [0] = 国内
# [1] = 国外
# [2] = github
function check_network() {
    local network=0
    ping -c 1 github.com > /dev/null
    if [ $? -eq 0 ]; then
        network=$((network + 4))
    fi
    ping -c 1 google.com > /dev/null
    if [ $? -eq 0 ]; then
        network=$((network + 2))
    fi
    ping -c 1 baidu.com > /dev/null
    if [ $? -eq 0 ]; then
        network=$((network + 1))
    fi
    echo $network
}

# 定义询问函数
function ask_user() {
    local question="$1"
    local answer

    # 循环直到用户输入有效答案
    while true; do
        read -p "$question (y/n): " answer
        case $answer in
            [Yy]*)
                return 0 ;; # 用户选择了"是"
            [Nn]*)
                return 1 ;; # 用户选择了"否"
            *)
                echo "无效的输入，请重新输入" ;;
        esac
    done
}

# 设置git
function setup_git() {
    git config --global core.editor "vim"
    git config --global pull.rebase true
    git config --global user.email "wuaqcn@qq.com"
    git config --global user.name "muyz"
}

# 设置vim
function setup_vim() {
    if ! command -v git >/dev/null 2>&1; then
        LOGW "Git没有安装，不能设置vim!"
        return 1
    fi

    if [ -d ~/.vim ]; then
        cd ~/.vim && git pull
    else
        git clone git@gitee.com:wuaq/vimcan.git ~/.vim
    fi
    sh ~/.vim/install.sh
}

# 编译安装zsh
function compile_install_zsh() {
    # 安装必要的编译工具和依赖项
    sudo yum install -y git gcc make autoconf ncurses-devel

    # 克隆Zsh源代码仓库
    git clone https://github.com/zsh-users/zsh.git

    # 切换到Zsh源代码目录
    cd zsh

    # 检查并选择要安装的Zsh版本
    git tag -l

    # 选择特定版本并检出代码
    git checkout -b zsh-5.8.1 zsh-5.8.1

    # 生成编译脚本
    ./Util/preconfig

    # 运行配置脚本
    ./configure

    # 编译Zsh
    make

    # 安装Zsh
    sudo make install

    # 将Zsh设置为默认Shell
    sudo chsh -s `which zsh`
}

