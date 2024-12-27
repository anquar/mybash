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
    LOGI "安装常用软件包..."
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
            LOGW "未知的操作系统($RELEASE)，跳过软件安装"
            ;;
    esac
}

# 主函数
main() {
    init_environment
    install_base_packages

    case "$CURRENT_SHELL" in
        "bash")
            setup_bash
            ;;
        "zsh")
            setup_zsh
            ;;
        *)
            LOGW "当前shell($CURRENT_SHELL)不支持，跳过配置"
            ;;
    esac

    # 设置时区和其他通用配置
    timedatectl set-timezone Asia/Shanghai
    setup_git
    setup_vim
}

main
