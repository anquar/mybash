#!/bin/bash

source ./support/base.sh
source ./support/func.sh

# 初始化环境
init_environment() {
    RELEASE=$(check_os)
    PKG_MANAGER=$(check_package_manager)
    CURRENT_SHELL=$(basename "$SHELL")

    # 设置包管理器
    if [[ x"${PKG_MANAGER}" == x"yum" ]]; then
        PKG_INSTALL_CMD="yum install -q -y"
    elif [[ x"${PKG_MANAGER}" == x"apt" ]]; then
        PKG_INSTALL_CMD="apt install -qq -y"
    else
        LOGE "无法确定包管理器" && exit 1
    fi
    [[ $(id -u) -ne 0 ]] && PKG_INSTALL_CMD="sudo ${PKG_INSTALL_CMD}"

    export RELEASE PKG_MANAGER PKG_INSTALL_CMD CURRENT_SHELL
}

# 安装基础软件包
install_base_packages() {
    case "$RELEASE" in
        "rhel" | "centos" | "anolis")
            $PKG_INSTALL_CMD curl tar vim fd-find ripgrep util-linux-user
            ;;
        "fedora")
            $PKG_INSTALL_CMD tar vim util-linux-user
            ;;
        "debian")
            $PKG_INSTALL_CMD curl tar vim fd-find ripgrep passwd
            ;;
        *)
            LOGE "未知的操作系统($RELEASE)" && exit 1
            ;;
    esac
}

# 主函数
main() {
    LOGI "开始安装..."
    LOGI "初始化环境..."
    init_environment
    LOGI "安装基础软件包..."
    install_base_packages
    LOGI "设置时区为Asia/Shanghai..."
    timedatectl set-timezone Asia/Shanghai
    LOGI "配置git..."
    setup_git
    LOGI "配置vim..."
    setup_vim

    case "$CURRENT_SHELL" in
        "bash")
            LOGI "配置bash..."
            setup_bash
            ;;
        "zsh")
            LOGI "配置zsh..."
            setup_zsh
            ;;
        *)
            LOGW "当前shell($CURRENT_SHELL)不支持，跳过配置"
            ;;
    esac
}

main
