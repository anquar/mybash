#!/bin/bash

source ./support/base.sh
source ./support/func.sh

RELEASE=$(check_os)
NETSTATUS=$(check_network)

# 根据网络情况选择执行模式
if [[ $NETSTATUS -eq 0 ]]; then
    if ask_user "无任何网络连接，是否继续执行?"; then
        echo "好的，我们继续执行"
    else
        LOGI "现在退出" && exit
    fi
    MODE=0
elif [[ $NETSTATUS -gt 0 && $NETSTATUS -le 3 ]]; then
    MODE=1
elif [[ $NETSTATUS -gt 4 && $NETSTATUS -le 7 ]]; then
    MODE=2
else
    LOGE "未知的网络状态，现在退出" && exit 1
fi

# 设置安装命令
PKG_INSTALL_CMD=''
if [[ x"${RELEASE}" == x"centos" && -x "$(command -v yum)" ]]; then
    PKG_INSTALL_CMD="yum install -q -y"
elif [[ -x "$(command -v apt)" ]]; then
    PKG_INSTALL_CMD="apt install -qq -y"
else
    LOGE "无法确定包管理器" && exit 1
fi
if [[ $(id -u) -ne 0 ]]; then
    PKG_INSTALL_CMD="sudo ${PKG_INSTALL_CMD}"
fi

# 检查zsh是否已安装
if ! command -v zsh &> /dev/null; then
    LOGI "zsh解释器未安装，开始安装..."
    $PKG_INSTALL_CMD zsh
fi
# 检查zsh是否是默认解释器
if [ $(basename "$SHELL") != "zsh" ]; then
    LOGI "zsh不是默认的解释器，开始设置为默认..."
    if [[ $(id -u) -eq 0 ]]; then
	chsh -s $(which zsh)
    else
        sudo chsh -s $(which zsh)
    fi
fi

LOGI "安装常用软件包..."
if [[ x"${RELEASE}" == x"centos" ]]; then
    $PKG_INSTALL_CMD curl wget git tar vim fd-find ripgrep util-linux-user
else
    $PKG_INSTALL_CMD curl wget git tar vim fd-find ripgrep passwd
fi

# 非本地模式才进一步配置
if [[ $MODE -ne 0 ]]; then
    if mv -n ~/.zshrc ~/.zshrc-backup-$(date +"%Y-%m-%d"); then
        LOGI "已将当前 .zshrc 备份到 .zshrc-backup-date"
    fi

    ZSH_CONFIG_PATH="$HOME/.config/zsh"
    mkdir -p ${ZSH_CONFIG_PATH}
    mkdir -p ${ZSH_CONFIG_PATH}/zshrc
    mkdir -p ~/.cache/zsh/
    LOGI "zsh配置路径为${ZSH_CONFIG_PATH}"
    cp -f .zshrc ~/
    cp -f config.zsh ${ZSH_CONFIG_PATH}/

    LOGI "开始安装 oh-my-zsh ..."
    if [ -d ${ZSH_CONFIG_PATH}/oh-my-zsh ]; then
        cd ${ZSH_CONFIG_PATH}/oh-my-zsh && git pull
    else
       if [[ $MODE -eq 1 ]]; then
           git clone --depth=1 https://gitee.com/mirrors/oh-my-zsh.git ${ZSH_CONFIG_PATH}/oh-my-zsh
       else
           git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git ${ZSH_CONFIG_PATH}/oh-my-zsh
       fi
    fi

    plugins=("zsh-autosuggestions" "zsh-syntax-highlighting" "zsh-completions" "zsh-history-substring-search")

    for plugin in "${plugins[@]}"; do
        LOGI "开始安装 oh-my-zsh 插件 ${plugin} ..."
        if [ -d ${ZSH_CONFIG_PATH}/oh-my-zsh/custom/plugins/${plugin} ]; then
            cd ${ZSH_CONFIG_PATH}/oh-my-zsh/custom/plugins/${plugin} && git pull
        else
            if [[ $MODE -eq 1 ]]; then
                git clone --depth=1 https://gitclone.com/github.com/zsh-users/${plugin}.git ${ZSH_CONFIG_PATH}/oh-my-zsh/custom/plugins/${plugin}
            else
                git clone --depth=1 https://github.com/zsh-users/${plugin}.git ${ZSH_CONFIG_PATH}/oh-my-zsh/custom/plugins/${plugin}
            fi
        fi
    done

    LOGI "开始安装主题..."
    if [ -d ${ZSH_CONFIG_PATH}/oh-my-zsh/custom/themes/powerlevel10k ]; then
        cd ${ZSH_CONFIG_PATH}/oh-my-zsh/custom/themes/powerlevel10k && git pull
    else
        if [[ $MODE -eq 1 ]]; then
            git clone --depth=1 https://gitclone.com/github.com/romkatv/powerlevel10k.git ${ZSH_CONFIG_PATH}/oh-my-zsh/custom/themes/powerlevel10k
        else
            git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CONFIG_PATH}/oh-my-zsh/custom/themes/powerlevel10k
        fi
    fi

    if [[ $MODE -eq 2 ]]; then
        LOGI "开始安装插件 fzf ..."
        if [ -d ${ZSH_CONFIG_PATH}/fzf ]; then
            cd ${ZSH_CONFIG_PATH}/fzf && git pull
            ${ZSH_CONFIG_PATH}/fzf/install --all --key-bindings --completion --no-update-rc
        else
            if [[ $MODE -eq 1 ]]; then
                git clone --depth 1 https://gitclone.com/github.com/junegunn/fzf.git ${ZSH_CONFIG_PATH}/fzf
            else
                git clone --depth 1 https://github.com/junegunn/fzf.git ${ZSH_CONFIG_PATH}/fzf
            fi
            ${ZSH_CONFIG_PATH}/fzf/install --all --key-bindings --completion --no-update-rc
        fi
    fi

    LOGI "开始安装插件 k ..."
    if [ -d ${ZSH_CONFIG_PATH}/oh-my-zsh/custom/plugins/k ]; then
        cd ${ZSH_CONFIG_PATH}/oh-my-zsh/custom/plugins/k && git pull
    else
        if [[ $MODE -eq 1 ]]; then
            git clone --depth 1 https://gitclone.com/github.com/supercrabtree/k ${ZSH_CONFIG_PATH}/oh-my-zsh/custom/plugins/k
        else
            git clone --depth 1 https://github.com/supercrabtree/k ${ZSH_CONFIG_PATH}/oh-my-zsh/custom/plugins/k
        fi
    fi

fi

#LOGI "开始设置时区..."
timedatectl set-timezone Asia/Shanghai

LOGI "开始设置git..."
setup_git
LOGI "开始设置vim..."
setup_vim
