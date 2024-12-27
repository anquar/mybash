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

# 检查包管理器
function check_package_manager() {
    local package_manager=""
    # 检查 apt 是否存在
    if [ -x "$(command -v apt)" ]; then
        package_manager="apt"
    elif [ -x "$(command -v yum)" ]; then
        # 检查 yum 是否存在
        package_manager="yum"
    else
        LOGE "未知的包管理器" && exit 1
    fi
    echo $package_manager
}

# 检查先决条件：wget和git是否安装
# 如果没有安装，则安装
function check_prerequisites() {
    local prerequisites=("wget" "git")
    local missing_pkgs=()

    # 检查每个必需的包是否已安装
    for pkg in "${prerequisites[@]}"; do
        if ! command -v $pkg >/dev/null 2>&1; then
            missing_pkgs+=($pkg)
        fi
    done

    # 如果有缺失的包,则安装
    PKG_MANAGER=$(check_package_manager)
    # 更新包管理器，检查是否是root
    if [[ $(id -u) -ne 0 ]]; then
        sudo $PKG_MANAGER update -y
    else
        $PKG_MANAGER update -y
    fi
    if [ ${#missing_pkgs[@]} -ne 0 ]; then
        LOGI "开始安装缺失的依赖包: ${missing_pkgs[*]}"
        if [[ $(id -u) -eq 0 ]]; then
            $PKG_MANAGER install -y ${missing_pkgs[@]}
        else
            sudo $PKG_MANAGER install -y ${missing_pkgs[@]}
        fi
    fi

    return 0
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
