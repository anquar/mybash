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
    git config --global user.name "wuaq"
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

# 通用的 git clone 函数
git_clone_or_pull() {
    local repo_url="$1"
    local target_dir="$2"

    if [ -d "$target_dir" ]; then
        cd "$target_dir" && git pull
        return
    fi

    git clone --depth=1 "${repo_url/github.com/ghub.wio.xyz\/github.com}" "$target_dir"
}

# 安装 shell 插件
install_shell_plugin() {
    local plugin_name="$1"
    local repo_url="$2"
    local target_dir="$3"

    LOGI "开始安装插件 ${plugin_name} ..."
    git_clone_or_pull "$repo_url" "$target_dir"
}

# 配置 bash
setup_bash() {
    LOGI "当前默认shell是bash，开始配置..."

    # 配置 bash_profile
    setup_bash_profile

    # 安装 oh-my-bash
    install_oh_my_bash

    # 非本地模式才安装插件
    [[ $MODE -ne 0 ]] && install_bash_plugins
}

# 配置 bash_profile
setup_bash_profile() {
    LOGI "检查 ~/.bash_profile 配置..."
    if [ -f ~/.bash_profile ]; then
        if ! grep -q "source ~/.bashrc" ~/.bash_profile; then
            echo -e "\nif [[ -f ~/.bashrc ]]; then\n  source ~/.bashrc\nfi" >> ~/.bash_profile
            LOGI "已添加 source ~/.bashrc 到 ~/.bash_profile"
        fi
    else
        echo -e "if [[ -f ~/.bashrc ]]; then\n  source ~/.bashrc\nfi" > ~/.bash_profile
        LOGI "已创建 ~/.bash_profile 并添加必要配置"
    fi
}

# 安装 oh-my-bash
install_oh_my_bash() {
    if [ -d ~/.oh-my-bash ]; then
        cd ~/.oh-my-bash && git pull
    else
        bash -c "$(curl -fsSL https://ghub.wio.xyz/github.com/ohmybash/oh-my-bash/raw/master/tools/install.sh)"
    fi
}

# 安装 bash 插件
install_bash_plugins() {
    LOGI "开始安装 oh-my-bash 插件..."
    mkdir -p ~/.oh-my-bash/custom/plugins

    # 安装自动补全
    install_shell_plugin "bash-autosuggestions" \
        "https://github.com/akinomyoga/ble.sh.git" \
        ~/.oh-my-bash/custom/plugins/bash-autosuggestions

    # 安装语法高亮
    install_shell_plugin "bash-syntax-highlighting" \
        "https://github.com/zdharma-continuum/fast-syntax-highlighting.git" \
        ~/.oh-my-bash/custom/plugins/bash-syntax-highlighting

    # 安装 fzf（仅完整模式）
    if [[ $MODE -eq 2 ]]; then
        install_shell_plugin "fzf" \
            "https://github.com/junegunn/fzf.git" \
            ~/.oh-my-bash/custom/plugins/fzf
        ~/.oh-my-bash/custom/plugins/fzf/install --all --key-bindings --completion --no-update-rc
    fi

    # 配置 bashrc
    setup_bashrc
}

# 配置 bashrc
setup_bashrc() {
    # 备份原有配置
    if [ -f ~/.bashrc ]; then
        if mv -n ~/.bashrc ~/.bashrc-backup-$(date +"%Y-%m-%d"); then
            LOGI "已将当前 .bashrc 备份到 .bashrc-backup-date"
        fi
    fi

    # 复制配置文件
    LOGI "复制 bash 配置文件..."
    cp -f config.bash ~/.bashrc
}

# 配置 zsh
setup_zsh() {
    [[ $MODE -eq 0 ]] && return
    LOGI "当前默认shell是zsh，开始配置..."

    # 设置配置目录
    ZSH_CONFIG_PATH="$HOME/.config/zsh"
    mkdir -p ${ZSH_CONFIG_PATH}/{zshrc,cache}

    # 备份原有配置
    if mv -n ~/.zshrc ~/.zshrc-backup-$(date +"%Y-%m-%d"); then
        LOGI "已将当前 .zshrc 备份到 .zshrc-backup-date"
    fi

    # 复制配置文件
    cp -f .zshrc ~/
    cp -f config.zsh ${ZSH_CONFIG_PATH}/

    # 安装 oh-my-zsh
    install_oh_my_zsh
    install_zsh_plugins
    install_zsh_theme
}

# 安装 oh-my-zsh
install_oh_my_zsh() {
    LOGI "开始安装 oh-my-zsh ..."
    if [ -d ${ZSH_CONFIG_PATH}/oh-my-zsh ]; then
        cd ${ZSH_CONFIG_PATH}/oh-my-zsh && git pull
    else
        git clone --depth=1 "https://github.com/ohmyzsh/ohmyzsh.git" ${ZSH_CONFIG_PATH}/oh-my-zsh
    fi
}

# 安装 zsh 插件
install_zsh_plugins() {
    local plugins=(
        "zsh-autosuggestions"
        "zsh-syntax-highlighting"
        "zsh-completions"
        "zsh-history-substring-search"
    )

    for plugin in "${plugins[@]}"; do
        install_shell_plugin "$plugin" \
            "https://github.com/zsh-users/${plugin}.git" \
            "${ZSH_CONFIG_PATH}/oh-my-zsh/custom/plugins/${plugin}"
    done

    # 安装 k 插件
    install_shell_plugin "k" \
        "https://github.com/supercrabtree/k" \
        "${ZSH_CONFIG_PATH}/oh-my-zsh/custom/plugins/k"

    # 安装 fzf（仅完整模式）
    if [[ $MODE -eq 2 ]]; then
        install_shell_plugin "fzf" \
            "https://github.com/junegunn/fzf.git" \
            "${ZSH_CONFIG_PATH}/fzf"
        ${ZSH_CONFIG_PATH}/fzf/install --all --key-bindings --completion --no-update-rc
    fi
}

# 安装 zsh 主题
install_zsh_theme() {
    LOGI "开始安装主题..."
    install_shell_plugin "powerlevel10k" \
        "https://github.com/romkatv/powerlevel10k.git" \
        "${ZSH_CONFIG_PATH}/oh-my-zsh/custom/themes/powerlevel10k"
}
