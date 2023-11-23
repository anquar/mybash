#!/bin/bash

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

function LOGW() {
    echo -e "${yellow}[W] $* ${plain}"
}

function LOGE() {
    echo -e "${red}[E] $* ${plain}"
}

function LOGI() {
    echo -e "${green}[I] $* ${plain}"
}

LOGI "Configuration starts!"

# check os
LOGI "Checking os-release ..."
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


# check network
github_access_status=$(curl -s -m 1 -IL github.com | grep 200)
if [ "$github_access_status" == "" ];then
    LOGW "The network cannot accesss github, please check it!"
fi


install_tool() {
    LOGI "Installing tools ..."
    if [[ x"${release}" == x"centos" ]]; then
        yum install -q wget git tar vim fd-find ripgrep util-linux-user -y
    else
        apt install -qq wget git tar vim fd-find ripgrep passwd -y
    fi
}

setup_vim() {
    if ! command -v git >/dev/null 2>&1; then
        LOGW "Git is not installed, cannot setup vim!"
        return 1
    fi

    LOGI "Setting vim ..."
    if [ -d ~/.vim_runtime ]; then
        cd ~/.vim_runtime && git pull
    else
        git clone -b basic git@gitee.com:wuaq/vimcan.git ~/.vim_runtime
    fi
    sh ~/.vim_runtime/install.sh
}

setup_git() {
    LOGI "Setting git global config ..."
    git config --global core.editor "vim"
    git config --global pull.rebase true
    git config --global user.email "wuaqcn@qq.com"
    git config --global user.name "muyz"
}

setup_more() {
    LOGI "Setting timezone ..."
    timedatectl set-timezone Asia/Shanghai
}

install_tool
setup_vim
setup_git
setup_more
LOGI "Configuration completed!" && exit

