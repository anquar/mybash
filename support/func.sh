#!/bin/bash

[ $(type -t LOGI) == "function" ] || source ./base.sh

# 检查系统类型
function check_os() {
    local release=""
    if [[ -f /etc/redhat-release ]]; then
        release="centos"
    elif cat /etc/issue | grep -Eqi "debian"; then
        release="debian"
    elif cat /etc/issue | grep -Eqi "ubuntu"; then
        release="ubuntu"
    elif cat /etc/issue | grep -Eqi "centos|red hat|redhat"; then
        release="centos"
    elif cat /proc/version | grep -Eqi "debian"; then
        release="debian"
    elif cat /proc/version | grep -Eqi "ubuntu"; then
        release="ubuntu"
    elif cat /proc/version | grep -Eqi "centos|red hat|redhat"; then
        release="centos"
    else
        LOGE "System version not detected, stopped running!" && exit 1
    fi
    echo $release
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

    if [ -d ~/.vim_runtime ]; then
        cd ~/.vim_runtime && git pull
    else
        git clone -b basic git@gitee.com:wuaq/vimcan.git ~/.vim_runtime
    fi
    sh ~/.vim_runtime/install.sh
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

