#!/bin/bash

# ------ make sure zsh wget and git are installed ------
if command -v zsh &> /dev/null && command -v git &> /dev/null && command -v wget &> /dev/null; then
    echo -e "zsh wget and git are already installed\n"
else
    if sudo apt install -y zsh git wget || sudo pacman -S zsh git wget || sudo dnf install -y zsh git wget || sudo yum install -y zsh git wget || sudo brew install git zsh wget || pkg install git zsh wget ; then
        echo -e "zsh wget and git Installed\n"
    else
        echo -e "Please install the following packages first, then try again: zsh git wget \n" && exit
    fi
fi


# ------ backup .zshrc ------
if mv -n ~/.zshrc ~/.zshrc-backup-$(date +"%Y-%m-%d"); then
    echo -e "Backed up the current .zshrc to .zshrc-backup-date\n"
fi

mkdir -p ~/.config/ezsh # the setup will be installed in here


# ------ install oh-my-zsh and plugins ------
echo -e "Installing oh-my-zsh\n"
if [ -d ~/.config/ezsh/oh-my-zsh ]; then
    echo -e "oh-my-zsh is already installed\n"
    git -C ~/.config/ezsh/oh-my-zsh remote set-url origin https://github.com/ohmyzsh/ohmyzsh.git
elif [ -d ~/.oh-my-zsh ]; then
    echo -e "oh-my-zsh in already installed at '~/.oh-my-zsh'. Moving it to '~/.config/ezsh/oh-my-zsh'"
    export ZSH="$HOME/.config/ezsh/oh-my-zsh"
    mv ~/.oh-my-zsh ~/.config/ezsh/oh-my-zsh
    git -C ~/.config/ezsh/oh-my-zsh remote set-url origin https://github.com/ohmyzsh/ohmyzsh.git
else
    git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git ~/.config/ezsh/oh-my-zsh
fi

cp -f .zshrc ~/
cp -f ezshrc.zsh ~/.config/ezsh/

mkdir -p ~/.config/ezsh/zshrc         # PLACE YOUR ZSHRC CONFIGURATIONS OVER THERE
mkdir -p ~/.cache/zsh/                # this will be used to store .zcompdump zsh completion cache files which normally clutter $HOME

if [ -f ~/.zcompdump ]; then
    mv ~/.zcompdump* ~/.cache/zsh/
fi

if [ -d ~/.config/ezsh/oh-my-zsh/plugins/zsh-autosuggestions ]; then
    cd ~/.config/ezsh/oh-my-zsh/plugins/zsh-autosuggestions && git pull
else
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ~/.config/ezsh/oh-my-zsh/plugins/zsh-autosuggestions
fi

if [ -d ~/.config/ezsh/oh-my-zsh/custom/plugins/zsh-syntax-highlighting ]; then
    cd ~/.config/ezsh/oh-my-zsh/custom/plugins/zsh-syntax-highlighting && git pull
else
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.config/ezsh/oh-my-zsh/custom/plugins/zsh-syntax-highlighting
fi

if [ -d ~/.config/ezsh/oh-my-zsh/custom/plugins/zsh-completions ]; then
    cd ~/.config/ezsh/oh-my-zsh/custom/plugins/zsh-completions && git pull
else
    git clone --depth=1 https://github.com/zsh-users/zsh-completions ~/.config/ezsh/oh-my-zsh/custom/plugins/zsh-completions
fi

if [ -d ~/.config/ezsh/oh-my-zsh/custom/plugins/zsh-history-substring-search ]; then
    cd ~/.config/ezsh/oh-my-zsh/custom/plugins/zsh-history-substring-search && git pull
else
    git clone --depth=1 https://github.com/zsh-users/zsh-history-substring-search ~/.config/ezsh/oh-my-zsh/custom/plugins/zsh-history-substring-search
fi


# ------ install fonts ------

echo -e "Installing Nerd Fonts version of Hack, Roboto Mono, DejaVu Sans Mono\n"

wget -q --show-progress -N https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Hack/Regular/complete/Hack%20Regular%20Nerd%20Font%20Complete.ttf -P ~/.fonts/
wget -q --show-progress -N https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/RobotoMono/Regular/complete/Roboto%20Mono%20Nerd%20Font%20Complete.ttf -P ~/.fonts/
wget -q --show-progress -N https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/DejaVuSansMono/Regular/complete/DejaVu%20Sans%20Mono%20Nerd%20Font%20Complete.ttf -P ~/.fonts/

fc-cache -fv ~/.fonts

if [ -d ~/.config/ezsh/oh-my-zsh/custom/themes/powerlevel10k ]; then
    cd ~/.config/ezsh/oh-my-zsh/custom/themes/powerlevel10k && git pull
else
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.config/ezsh/oh-my-zsh/custom/themes/powerlevel10k
fi

if [ -d ~/.~/.config/ezsh/fzf ]; then
    cd ~/.config/ezsh/fzf && git pull
    ~/.config/ezsh/fzf/install --all --key-bindings --completion --no-update-rc
else
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.config/ezsh/fzf
    ~/.config/ezsh/fzf/install --all --key-bindings --completion --no-update-rc
fi

if [ -d ~/.config/ezsh/oh-my-zsh/custom/plugins/k ]; then
    cd ~/.config/ezsh/oh-my-zsh/custom/plugins/k && git pull
else
    git clone --depth 1 https://github.com/supercrabtree/k ~/.config/ezsh/oh-my-zsh/custom/plugins/k
fi

if [ -d ~/.config/ezsh/marker ]; then
    cd ~/.config/ezsh/marker && git pull
else
    git clone --depth 1 https://github.com/jotyGill/marker ~/.config/ezsh/marker
fi

if ~/.config/ezsh/marker/install.py; then
    echo -e "Installed Marker\n"
else
    echo -e "Marker Installation Had Issues\n"
fi

echo -e "\nSudo access is needed to change default shell\n"

if chsh -s $(which zsh) && /bin/zsh -i -c 'omz update'; then
    echo -e "Installation Successful, exit terminal and enter a new session"
else
    echo -e "Something is wrong"
fi
exit


git config --global core.editor "vim"

