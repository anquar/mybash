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


# check os
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
    LOGE "System version not detected, stopped running!\n" && exit 1
fi


github_access_status=$(curl -s -m 1 -IL github.com | grep 200)
if [ "$github_access_status" == "" ];then
    LOGE "The network condition is not satisfactory, please check and try again.!\n" && exit 1
fi


install_base() {
    if [[ x"${release}" == x"centos" ]]; then
        yum install wget git vim zsh util-linux-user -y
    else
        apt install wget git vim zsh passwd -y
    fi
}


backup_zshrc() {
    if mv -n ~/.zshrc ~/.zshrc-backup-$(date +"%Y-%m-%d"); then
        LOGI "Backed up the current .zshrc to .zshrc-backup-date\n"
    fi
}


INSTALL_PATH="$HOME/.config/muyz"
mkdir -p ${INSTALL_PATH}


install_ohmyzsh_with_plugins() {
    LOGI "Installing oh-my-zsh\n"
    if [ -d ${INSTALL_PATH}/oh-my-zsh ]; then
        LOGW "oh-my-zsh is already installed\n"
        git -C ${INSTALL_PATH}/oh-my-zsh remote set-url origin https://github.com/ohmyzsh/ohmyzsh.git
    elif [ -d ~/.oh-my-zsh ]; then
        LOGI "oh-my-zsh in already installed at '~/.oh-my-zsh'. Moving it to '${INSTALL_PATH}/oh-my-zsh'\n"
        export ZSH="${INSTALL_PATH}/oh-my-zsh"
        mv ~/.oh-my-zsh ${INSTALL_PATH}/oh-my-zsh
        git -C ${INSTALL_PATH}/oh-my-zsh remote set-url origin https://github.com/ohmyzsh/ohmyzsh.git
    else
        git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git ${INSTALL_PATH}/oh-my-zsh
    fi

    cp -f .zshrc ~/
    cp -f ezshrc.zsh ${INSTALL_PATH}/

    mkdir -p ${INSTALL_PATH}/zshrc # PLACE YOUR ZSHRC CONFIGURATIONS OVER THERE
    mkdir -p ~/.cache/zsh/ # this will be used to store .zcompdump zsh completion cache files which normally clutter $HOME

    if [ -f ~/.zcompdump ]; then
        mv ~/.zcompdump* ~/.cache/zsh/
    fi

    if [ -d ${INSTALL_PATH}/oh-my-zsh/plugins/zsh-autosuggestions ]; then
        cd ${INSTALL_PATH}/oh-my-zsh/plugins/zsh-autosuggestions && git pull
    else
        git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ${INSTALL_PATH}/oh-my-zsh/plugins/zsh-autosuggestions
    fi

    if [ -d ${INSTALL_PATH}/oh-my-zsh/custom/plugins/zsh-syntax-highlighting ]; then
        cd ${INSTALL_PATH}/oh-my-zsh/custom/plugins/zsh-syntax-highlighting && git pull
    else
        git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git ${INSTALL_PATH}/oh-my-zsh/custom/plugins/zsh-syntax-highlighting
    fi

    if [ -d ${INSTALL_PATH}/oh-my-zsh/custom/plugins/zsh-completions ]; then
        cd ${INSTALL_PATH}/oh-my-zsh/custom/plugins/zsh-completions && git pull
    else
        git clone --depth=1 https://github.com/zsh-users/zsh-completions ${INSTALL_PATH}/oh-my-zsh/custom/plugins/zsh-completions
    fi

    if [ -d ${INSTALL_PATH}/oh-my-zsh/custom/plugins/zsh-history-substring-search ]; then
        cd ${INSTALL_PATH}/oh-my-zsh/custom/plugins/zsh-history-substring-search && git pull
    else
        git clone --depth=1 https://github.com/zsh-users/zsh-history-substring-search ${INSTALL_PATH}/oh-my-zsh/custom/plugins/zsh-history-substring-search
    fi
}


install_font() {
    LOGI "Installing Nerd Fonts version of Hack, Roboto Mono, DejaVu Sans Mono\n"

    wget -q --show-progress -N https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Hack/Regular/complete/Hack%20Regular%20Nerd%20Font%20Complete.ttf -P ~/.fonts/
    wget -q --show-progress -N https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/RobotoMono/Regular/complete/Roboto%20Mono%20Nerd%20Font%20Complete.ttf -P ~/.fonts/
    wget -q --show-progress -N https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/DejaVuSansMono/Regular/complete/DejaVu%20Sans%20Mono%20Nerd%20Font%20Complete.ttf -P ~/.fonts/

    fc-cache -fv ~/.fonts
}


setup_zsh_theme() {
    if [ -d ${INSTALL_PATH}/oh-my-zsh/custom/themes/powerlevel10k ]; then
        cd ${INSTALL_PATH}/oh-my-zsh/custom/themes/powerlevel10k && git pull
    else
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${INSTALL_PATH}/oh-my-zsh/custom/themes/powerlevel10k
    fi
}


install_other_tool() {
    if [ -d ~/.${INSTALL_PATH}/fzf ]; then
        cd ${INSTALL_PATH}/fzf && git pull
        ${INSTALL_PATH}/fzf/install --all --key-bindings --completion --no-update-rc
    else
        git clone --depth 1 https://github.com/junegunn/fzf.git ${INSTALL_PATH}/fzf
        ${INSTALL_PATH}/fzf/install --all --key-bindings --completion --no-update-rc
    fi

    if [ -d ${INSTALL_PATH}/oh-my-zsh/custom/plugins/k ]; then
        cd ${INSTALL_PATH}/oh-my-zsh/custom/plugins/k && git pull
    else
        git clone --depth 1 https://github.com/supercrabtree/k ${INSTALL_PATH}/oh-my-zsh/custom/plugins/k
    fi

    if [ -d ${INSTALL_PATH}/marker ]; then
        cd ${INSTALL_PATH}/marker && git pull
    else
        git clone --depth 1 https://github.com/jotyGill/marker ${INSTALL_PATH}/marker
    fi

    if ${INSTALL_PATH}/marker/install.py; then
        LOGI "Installed Marker\n"
    else
        LOGE "Marker Installation Had Issues\n"
    fi
}


change_shell() {
    if chsh -s $(which zsh) && ${SHELL} -i -c 'omz update'; then
        LOGI "Installation Successful, exit terminal and enter a new session"
    else
        LOGE "Something is wrong"
    fi
}

more_setup() {
    # setting git
    git config --global core.editor "vim"
    git config --global pull.rebase true
    git config --global user.email "wuaqcn@qq.com"
    git config --global user.name "muyz"

    timedatectl set-timezone Asia/Shanghai
}


install_base
backup_zshrc
install_ohmyzsh_with_plugins
install_font
setup_zsh_theme
install_other_tool
change_shell
more_setup
exit
