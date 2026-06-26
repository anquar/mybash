#!/bin/bash

# ==============================================================================
# setup-bash.sh
# BASH 自动配置脚本
# 功能：配置 Bash (Oh-My-Bash), Vim (Plug+插件), 安装 fd/rg
# 支持：交互/静默安装，在线/离线安装，资源一键下载，一键卸载
# ==============================================================================

# --- 全局变量与配置 ---
ASSETS_DIR="bash-assets"
BACKUP_PREFIX=".backup-"
BACKUP_SUFFIX="${BACKUP_PREFIX}$(date +%Y%m%d%H%M%S)"
IS_SILENT=false
DO_DOWNLOAD=false
DO_UNINSTALL=false

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
PLAIN='\033[0m'

# --- 资源定义 ---
# 仓库地址
URL_OH_MY_BASH="https://github.com/ohmybash/oh-my-bash.git"
URL_VIM_PLUG="https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"

# 工具版本与下载地址 (默认为 Linux x86_64 musl，兼容性最好)
# 如果需要其他架构，请修改此处
FD_VERSION="10.2.0"
RG_VERSION="14.1.1"
URL_FD="https://github.com/sharkdp/fd/releases/download/v${FD_VERSION}/fd-v${FD_VERSION}-x86_64-unknown-linux-musl.tar.gz"
URL_RG="https://github.com/BurntSushi/ripgrep/releases/download/${RG_VERSION}/ripgrep-${RG_VERSION}-x86_64-unknown-linux-musl.tar.gz"

# Bash 插件
declare -A BASH_PLUGINS=(
    ["zoxide"]="https://github.com/ajeetdsouza/zoxide.git"
    ["fzf"]="https://github.com/junegunn/fzf.git"
)

# Vim 插件
declare -A VIM_PLUGINS=(
    ["catppuccin"]="https://github.com/catppuccin/vim.git"
    ["lightline"]="https://github.com/itchyny/lightline.vim.git"
    ["vim-gitgutter"]="https://github.com/airblade/vim-gitgutter.git"
    ["git-blame"]="https://github.com/zivyangll/git-blame.vim.git"
    ["nerdtree"]="https://github.com/preservim/nerdtree.git"
    ["fzf.vim"]="https://github.com/junegunn/fzf.git"
    ["nerdtree-git-plugin"]="https://github.com/Xuyuanp/nerdtree-git-plugin.git"
    ["vim-devicons"]="https://github.com/ryanoasis/vim-devicons.git"
    ["nerdcommenter"]="https://github.com/preservim/nerdcommenter.git"
    ["vim-easymotion"]="https://github.com/easymotion/vim-easymotion.git"
)

# --- 内嵌配置文件内容 ---

# 1. 生成 .bashrc 内容
generate_bashrc_content() {
    cat << 'EOF'
# Path to your oh-my-bash installation.
export OSH=~/.oh-my-bash

# 设置主题
OSH_THEME="powerbash10k"

# 启用插件
plugins=(
    git
    colored-man-pages
    pyenv
    sudo
    zoxide
)

# 如果安装了 fzf，则加载它
[ -f ~/.fzf.bash ] && source ~/.fzf.bash
# 设置 PATH (包含 ~/.local/bin 以支持 fd/rg)
export PATH=~/.local/bin:$PATH

# 加载 oh-my-bash
if [ -f "$OSH/oh-my-bash.sh" ]; then
    source "$OSH/oh-my-bash.sh"
fi

# --- 工具别名配置 (fd & ripgrep) ---
# 自动处理 fdfind (Debian/Ubuntu) 别名
if ! command -v fd &>/dev/null && command -v fdfind &>/dev/null; then
    alias fd='fdfind'
fi
# 确保 rg 别名存在 (通常不需要，但为了符合要求)
if command -v rg &>/dev/null; then
    alias rg='rg'
fi

# --- 用户自定义配置 (来自 MyBash) ---
alias ll='ls -la'
alias la='ls -A'
alias myip="wget -qO- http://ipv4.wtfismyip.com/text"
alias l="ls -lAhrtF"
alias e="exit"

# 设置历史记录
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoreboth
shopt -s histappend

# CUSTOM FUNCTIONS
function date() {
    if [ $# -eq 0 ]; then
        command date "+%Y-%m-%d %A %H:%M:%S %Z"
    else
        command date "$@"
    fi
}

function speedtest() {
    if command -v python3 &>/dev/null; then
        curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python3 -
    else
        echo "Python3 not found."
    fi
}

function backtrace() {
    curl https://raw.githubusercontent.com/zhanghanyun/backtrace/main/install.sh -sSf | sh
}

function yabs() {
    curl -sL https://yabs.sh | bash
}

# Find dictionary definition
dict() {
    if [ "$3" ]; then
        curl "dict://dict.org/d:$1 $2 $3"
    elif [ "$2" ]; then
        curl "dict://dict.org/d:$1 $2"
    else
        curl "dict://dict.org/d:$1"
    fi
}

# Find geo info from IP
ipgeo() {
    if [ "$1" ]; then
        curl "http://api.db-ip.com/v2/free/$1"
    else
        curl "http://api.db-ip.com/v2/free/$(myip)"
    fi
    echo ""
}
EOF
}

# 2. 生成 .vimrc 内容
generate_vimrc_content() {
    cat << 'EOF'
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => 通用
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set history=500
set helplang=cn
set mouse=a
filetype plugin on
filetype indent on
set autoread
au FocusGained,BufEnter * checktime
let mapleader = ' '
command! W execute 'w !sudo tee % > /dev/null' <bar> edit!

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => VIM 用户界面
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set so=3
set number
set relativenumber
set wildmenu
set wildignore=*.o,*~,*.pyc,*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store
set ruler
set cmdheight=1
set hid
set backspace=eol,start,indent
set whichwrap+=<,>,h,l
set ignorecase
set smartcase
set hlsearch
set incsearch
set lazyredraw
set magic
set showmatch
set mat=2
set noerrorbells
set novisualbell
set t_vb=
set tm=500
set foldcolumn=0

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => 颜色和字体
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
syntax enable
set regexpengine=0
if exists('+termguicolors')
    set t_Co=256
    set termguicolors
endif
set termencoding=utf-8
set encoding=utf-8
set fileencodings=utf-8,ucs-bom,gbk,cp936,gb2312,gb18030
set ffs=unix,dos,mac

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => 插件配置 (vim-plug)
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call plug#begin('~/.vim/plugged')
Plug 'catppuccin/vim', { 'as': 'catppuccin.vim' }
Plug 'itchyny/lightline.vim', { 'as': 'lightline.vim' }
Plug 'airblade/vim-gitgutter', { 'as': 'gitgutter.vim' }
Plug 'zivyangll/git-blame.vim'
Plug 'preservim/nerdtree', { 'as': 'nerdtree.vim' }
Plug 'junegunn/fzf', { 'as': 'fzf.vim' }
Plug 'Xuyuanp/nerdtree-git-plugin', { 'as': 'nerdtree-git.vim' }
Plug 'ryanoasis/vim-devicons', { 'as': 'nerdtree-devicons.vim' }
Plug 'preservim/nerdcommenter', { 'as': 'nerdcommenter.vim' }
Plug 'easymotion/vim-easymotion', { 'as': 'easymotion.vim' }
call plug#end()

let g:NERDTreeGitStatusUseNerdFonts = 1
let g:NERDTreeGitStatusShowIgnored = 1
let g:NERDTreeGitStatusShowClean = 1
let g:NERDCreateDefaultMappings = 1
let g:NERDSpaceDelims = 1
let g:NERDCompactSexyComs = 1
let g:NERDCommentEmptyLines = 1
let g:NERDTrimTrailingWhitespace = 1
let g:EasyMotion_do_mapping = 0
let g:EasyMotion_smartcase = 1

try
    colorscheme catppuccin_mocha
catch
endtry

set laststatus=2
let g:lightline = {
      \ 'colorscheme': 'catppuccin_mocha',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ], [ 'readonly', 'filename', 'modified' ] ],
      \   'right': [ [ 'lineinfo' ], [ 'percent' ], [ 'searchcount', 'fileformat', 'fileencoding', 'filetype' ] ]
      \ },
      \ 'component_function': { 'searchcount': 'LightlineSearchCount' },
      \ }

function! LightlineSearchCount() abort
  if !v:hlsearch
    return ''
  endif
  try
    let result = searchcount(#{recompute: 1, maxcount: -1})
    if empty(result) || result.total ==# 0
      return ''
    endif
    if result.incomplete ==# 1
      return printf(' [?/?]')
    elseif result.incomplete ==# 2
      if result.total > result.maxcount && result.current > result.maxcount
        return printf(' [>%d/>%d]', result.current, result.total)
      elseif result.total > result.maxcount
        return printf(' [%d/>%d]', result.current, result.total)
      endif
    endif
    return printf(' [%d/%d]', result.current, result.total)
  catch
    return ''
  endtry
endfunction
augroup searchcount_statusline
  autocmd!
  autocmd CursorMoved * call lightline#update()
augroup END

nnoremap <leader>g :<C-u>call gitblame#echo()<CR>
nnoremap <leader>n :NERDTreeFind<CR>
nnoremap <leader>e :NERDTreeToggle<CR>
nmap <leader>s <Plug>(easymotion-overwin-f2)
nmap <leader>j <Plug>(easymotion-j)
nmap <leader>k <Plug>(easymotion-k)
map  <leader>f <Plug>(easymotion-bd-f)
nmap <leader>f <Plug>(easymotion-overwin-f)
map  <Leader>w <Plug>(easymotion-bd-w)
nmap <Leader>w <Plug>(easymotion-overwin-w)

set nobackup
set nowb
set noswapfile
set expandtab
set smarttab
set shiftwidth=4
set tabstop=4
set lbr
set tw=1000
set ai
set si
set wrap

vnoremap <silent> * :<C-u>call VisualSelection('', '')<CR>/<C-R>=@/<CR><CR>
vnoremap <silent> # :<C-u>call VisualSelection('', '')<CR>?<C-R>=@/<CR><CR>

map <silent> <leader><cr> :noh<cr>
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l
map <leader>bc :Bclose<cr>:tabclose<cr>gT
map <leader>ba :bufdo bd<cr>
map <leader>bn :e ~/buffer<cr>
map <leader>l :bnext<cr>
map <leader>h :bprevious<cr>
map <leader>tn :tabnew<cr>
map <leader>to :tabonly<cr>
map <leader>tc :tabclose<cr>
map <leader>tm :tabmove
map <leader>tt :tabnext<cr>

let g:lasttab = 1
nmap <leader>tl :exe "tabn ".g:lasttab<CR>
au TabLeave * let g:lasttab = tabpagenr()
map <leader>te :tabedit <C-r>=escape(expand("%:p:h"), " ")<cr>/
map <leader>cd :cd %:p:h<cr>:pwd<cr>

try
  set switchbuf=useopen,usetab,newtab
  set stal=2
catch
endtry

au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

map 0 ^
inoremap jk <ESC>
nmap <S-j> mz:m+<cr>`z
nmap <S-k> mz:m-2<cr>`z
vmap <S-j> :m'>+<cr>`<my`>mzgv`yo`z
vmap <S-k> :m'<-2<cr>`>my`<mzgv`yo`z

fun! CleanExtraSpaces()
    let save_cursor = getpos(".")
    let old_query = getreg('/')
    silent! %s/\s\+$//e
    call setpos('.', save_cursor)
    call setreg('/', old_query)
endfun
if has("autocmd")
    autocmd BufWritePre *.txt,*.js,*.py,*.wiki,*.sh,*.coffee :call CleanExtraSpaces()
endif

noremap <Leader>m mmHmt:%s/<C-V><cr>//ge<cr>'tzt'm
map <leader>q :qa!<cr>
map <leader>x :e ~/buffer.md<cr>
map <leader>p :setlocal paste!<cr>
map <leader>i :set nu relativenumber<cr>
map <leader>o :set nonu norelativenumber<cr>

function! HasPaste()
    if &paste
        return 'PASTE MODE  '
    endif
    return ''
endfunction

command! Bclose call <SID>BufcloseCloseIt()
function! <SID>BufcloseCloseIt()
    let l:currentBufNum = bufnr("%")
    let l:alternateBufNum = bufnr("#")
    if buflisted(l:alternateBufNum)
        buffer #
    else
        bnext
    endif
    if bufnr("%") == l:currentBufNum
        new
    endif
    if buflisted(l:currentBufNum)
        execute("bdelete! ".l:currentBufNum)
    endif
endfunction

function! CmdLine(str)
    call feedkeys(":" . a:str)
endfunction

function! VisualSelection(direction, extra_filter) range
    let l:saved_reg = @"
    execute "normal! vgvy"
    let l:pattern = escape(@", "\\/.*'$^~[]")
    let l:pattern = substitute(l:pattern, "\n$", "", "")
    if a:direction == 'gv'
        call CmdLine("Ack '" . l:pattern . "' " )
    elseif a:direction == 'replace'
        call CmdLine("%s" . '/'. l:pattern . '/')
    endif
    let @/ = l:pattern
    let @" = l:saved_reg
endfunction
EOF
}

# --- 辅助函数 ---

log_info() { echo -e "${GREEN}[INFO] $1${PLAIN}"; }
log_warn() { echo -e "${YELLOW}[WARN] $1${PLAIN}"; }
log_error() { echo -e "${RED}[ERROR] $1${PLAIN}"; }

ask_user() {
    if [ "$IS_SILENT" = true ]; then return 0; fi
    while true; do
        read -p "$1 (y/n): " answer
        case $answer in
            [Yy]*) return 0 ;;
            [Nn]*) return 1 ;;
            *) echo "请输入 y 或 n" ;;
        esac
    done
}

check_cmd() {
    command -v "$1" >/dev/null 2>&1
}

# 获取资源路径
get_source_path() {
    local name="$1"
    local url="$2"
    local local_path="./${ASSETS_DIR}/${name}"
    if [ -e "$local_path" ]; then echo "$local_path"; else echo "$url"; fi
}

# --- 核心逻辑：工具安装 (fd, rg) ---
install_binaries() {
    if ! ask_user "是否安装 fd 和 ripgrep (rg) 工具?"; then return; fi

    log_info "正在配置 fd 和 ripgrep..."
    mkdir -p "$HOME/.local/bin"

    # 安装函数
    local install_tool=false
    local pkg_cmd=""

    # 尝试检测包管理器
    if check_cmd apt; then pkg_cmd="apt install -y";
    elif check_cmd yum; then pkg_cmd="yum install -y"; fi

    # --- 安装 FD ---
    if check_cmd fd; then
        log_info "fd 已安装，跳过。"
    else
        log_info "安装 fd..."
        local fd_archive="./${ASSETS_DIR}/archives/fd.tar.gz"
        local installed=false

        # 1. 优先尝试离线包
        if [ -f "$fd_archive" ]; then
            log_info "使用离线包安装 fd..."
            tar -xzf "$fd_archive" -C /tmp
            # 查找解压后的二进制文件 (目录名可能包含版本)
            find /tmp -name "fd" -type f -exec cp {} "$HOME/.local/bin/" \;
            chmod +x "$HOME/.local/bin/fd"
            installed=true
            rm -rf /tmp/fd*
        fi

        # 2. 如果离线失败，尝试在线下载二进制 (最稳妥的别名方式)
        if [ "$installed" = false ]; then
            log_info "尝试在线下载 fd 二进制..."
            if curl -L "$URL_FD" -o /tmp/fd.tar.gz; then
                tar -xzf /tmp/fd.tar.gz -C /tmp
                find /tmp -name "fd" -type f -exec cp {} "$HOME/.local/bin/" \;
                chmod +x "$HOME/.local/bin/fd"
                installed=true
                rm -rf /tmp/fd* /tmp/fd.tar.gz
            else
                log_warn "在线下载 fd 失败，尝试系统包管理器..."
            fi
        fi

        # 3. 最后尝试包管理器 (fd-find)
        if [ "$installed" = false ] && [ -n "$pkg_cmd" ]; then
            if [[ "$pkg_cmd" == *"apt"* ]]; then
                sudo $pkg_cmd fd-find
            else
                sudo $pkg_cmd fd-find || sudo $pkg_cmd fd
            fi
        fi
    fi

    # --- 安装 Ripgrep ---
    if check_cmd rg; then
        log_info "ripgrep (rg) 已安装，跳过。"
    else
        log_info "安装 ripgrep (rg)..."
        local rg_archive="./${ASSETS_DIR}/archives/rg.tar.gz"
        local installed=false

        if [ -f "$rg_archive" ]; then
            log_info "使用离线包安装 rg..."
            tar -xzf "$rg_archive" -C /tmp
            find /tmp -name "rg" -type f -exec cp {} "$HOME/.local/bin/" \;
            chmod +x "$HOME/.local/bin/rg"
            installed=true
            rm -rf /tmp/ripgrep*
        fi

        if [ "$installed" = false ]; then
            log_info "尝试在线下载 rg 二进制..."
            if curl -L "$URL_RG" -o /tmp/rg.tar.gz; then
                tar -xzf /tmp/rg.tar.gz -C /tmp
                find /tmp -name "rg" -type f -exec cp {} "$HOME/.local/bin/" \;
                chmod +x "$HOME/.local/bin/rg"
                installed=true
                rm -rf /tmp/ripgrep* /tmp/rg.tar.gz
            fi
        fi

        if [ "$installed" = false ] && [ -n "$pkg_cmd" ]; then
            sudo $pkg_cmd ripgrep
        fi
    fi
}

# --- 核心逻辑：卸载 ---
uninstall_env() {
    log_warn "危险操作: 即将卸载配置的环境。"
    if ! ask_user "确定要继续卸载吗?"; then exit 0; fi

    log_info "清理 Bash 环境..."
    rm -rf "$HOME/.oh-my-bash"
    rm -f "$HOME/.fzf.bash"

    # 清理安装的二进制工具
    rm -f "$HOME/.local/bin/fd"
    rm -f "$HOME/.local/bin/rg"
    log_info "已删除 ~/.local/bin 下的 fd 和 rg"

    # 还原 .bashrc
    local bashrc_backup=$(ls -t "$HOME/.bashrc${BACKUP_PREFIX}"* 2>/dev/null | head -n1)
    if [ -n "$bashrc_backup" ]; then
        cp -f "$bashrc_backup" "$HOME/.bashrc"
        log_info "已还原 .bashrc"
    fi

    log_info "清理 Vim 环境..."
    rm -f "$HOME/.vim/autoload/plug.vim"
    rm -rf "$HOME/.vim/plugged"

    # 还原 .vimrc
    local vimrc_backup=$(ls -t "$HOME/.vimrc${BACKUP_PREFIX}"* 2>/dev/null | head -n1)
    if [ -n "$vimrc_backup" ]; then
        cp -f "$vimrc_backup" "$HOME/.vimrc"
        log_info "已还原 .vimrc"
    fi

    log_info "卸载完成！"
}

# --- 核心逻辑：下载资源 ---
download_resources() {
    log_info "开始下载资源到: ${ASSETS_DIR}..."
    mkdir -p "${ASSETS_DIR}"

    # 1. 下载 Oh My Bash
    if [ ! -d "${ASSETS_DIR}/oh-my-bash" ]; then
        log_info "下载 Oh My Bash..."
        git clone --depth=1 "$URL_OH_MY_BASH" "${ASSETS_DIR}/oh-my-bash"
    fi

    # 2. 下载 vim-plug
    if [ ! -f "${ASSETS_DIR}/plug.vim" ]; then
        log_info "下载 Vim Plug..."
        curl -fLo "${ASSETS_DIR}/plug.vim" --create-dirs "$URL_VIM_PLUG"
    fi

    # 3. 下载工具二进制 (fd, rg)
    mkdir -p "${ASSETS_DIR}/archives"
    log_info "下载二进制工具包 (fd, rg)..."
    if [ ! -f "${ASSETS_DIR}/archives/fd.tar.gz" ]; then
        log_info "Downloading fd..."
        curl -L "$URL_FD" -o "${ASSETS_DIR}/archives/fd.tar.gz"
    fi
    if [ ! -f "${ASSETS_DIR}/archives/rg.tar.gz" ]; then
        log_info "Downloading ripgrep..."
        curl -L "$URL_RG" -o "${ASSETS_DIR}/archives/rg.tar.gz"
    fi

    # 4. 下载 Bash 插件
    log_info "下载 Bash 插件..."
    mkdir -p "${ASSETS_DIR}/bash_plugins"
    for name in "${!BASH_PLUGINS[@]}"; do
        if [ ! -d "${ASSETS_DIR}/bash_plugins/$name" ]; then
            git clone --depth=1 "${BASH_PLUGINS[$name]}" "${ASSETS_DIR}/bash_plugins/$name"
        fi
    done

    # 5. 下载 Vim 插件
    log_info "下载 Vim 插件..."
    mkdir -p "${ASSETS_DIR}/vim_plugins"
    for name in "${!VIM_PLUGINS[@]}"; do
        if [ ! -d "${ASSETS_DIR}/vim_plugins/$name" ]; then
            git clone --depth=1 "${VIM_PLUGINS[$name]}" "${ASSETS_DIR}/vim_plugins/$name"
        fi
    done

    log_info "所有资源已下载完毕。"
}

# --- 核心逻辑：安装 Bash ---
install_bash() {
    if ! ask_user "是否安装/配置 Bash 环境?"; then return; fi
    log_info "正在配置 Bash..."

    local omb_dest="$HOME/.oh-my-bash"
    local omb_src=$(get_source_path "oh-my-bash" "$URL_OH_MY_BASH")

    if [ -d "$omb_dest" ]; then mv "$omb_dest" "${omb_dest}${BACKUP_SUFFIX}"; fi

    if [ -d "$omb_src" ]; then cp -r "$omb_src" "$omb_dest";
    else git clone --depth=1 "$omb_src" "$omb_dest"; fi

    mkdir -p "$omb_dest/custom/plugins"

    # 安装 Zoxide & FZF (Bash)
    for plugin in "zoxide" "fzf"; do
        local p_src=$(get_source_path "bash_plugins/$plugin" "${BASH_PLUGINS[$plugin]}")
        local p_dest="$omb_dest/custom/plugins/$plugin"
        if [ ! -d "$p_dest" ]; then
            if [ -d "$p_src" ]; then cp -r "$p_src" "$p_dest";
            else git clone --depth=1 "$p_src" "$p_dest"; fi
        fi
    done

    # 触发子安装脚本
    [ -f "$omb_dest/custom/plugins/zoxide/install.sh" ] && sh "$omb_dest/custom/plugins/zoxide/install.sh"
    "$omb_dest/custom/plugins/fzf/install" --all --key-bindings --completion --no-update-rc

    # 替换 .bashrc
    if [ -f "$HOME/.bashrc" ]; then mv "$HOME/.bashrc" "$HOME/.bashrc${BACKUP_SUFFIX}"; fi
    generate_bashrc_content > "$HOME/.bashrc"
}

# --- 核心逻辑：安装 Vim ---
install_vim() {
    if ! check_cmd vim; then
        log_warn "未检测到 vim，请先安装。"
        if ! ask_user "忽略 vim 安装继续?"; then return; fi
    fi
    if ! ask_user "是否安装/配置 Vim 环境?"; then return; fi

    log_info "正在配置 Vim..."
    if [ -f "$HOME/.vimrc" ]; then mv "$HOME/.vimrc" "$HOME/.vimrc${BACKUP_SUFFIX}"; fi
    generate_vimrc_content > "$HOME/.vimrc"

    local plug_path="$HOME/.vim/autoload/plug.vim"
    local plug_src=$(get_source_path "plug.vim" "$URL_VIM_PLUG")
    mkdir -p "$HOME/.vim/autoload"

    if [ -f "$plug_src" ]; then cp "$plug_src" "$plug_path";
    else curl -fLo "$plug_path" --create-dirs "$plug_src"; fi

    mkdir -p "$HOME/.vim/plugged"
    local has_local_plugins=false
    if [ -d "./${ASSETS_DIR}/vim_plugins" ]; then has_local_plugins=true; fi

    if [ "$has_local_plugins" = true ]; then
        log_info "从本地安装 Vim 插件..."
        for name in "${!VIM_PLUGINS[@]}"; do
             if [ -d "./${ASSETS_DIR}/vim_plugins/$name" ]; then
                 rm -rf "$HOME/.vim/plugged/$name"
                 cp -r "./${ASSETS_DIR}/vim_plugins/$name" "$HOME/.vim/plugged/"
             fi
        done
    else
        log_info "在线安装 Vim 插件..."
        vim +PlugInstall +qall
    fi
}

# --- 主函数 ---
main() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -s|--silent) IS_SILENT=true; shift ;;
            -d|--download) DO_DOWNLOAD=true; shift ;;
            -u|--uninstall) DO_UNINSTALL=true; shift ;;
            -h|--help) echo "Usage: $0 [-s] [-d] [-u]"; exit 0 ;;
            *) echo "Unknown option: $1"; exit 1 ;;
        esac
    done

    if [ "$DO_UNINSTALL" = true ]; then uninstall_env; exit 0; fi
    if ! check_cmd git; then log_error "Need git."; exit 1; fi
    if [ "$DO_DOWNLOAD" = true ]; then download_resources; exit 0; fi

    if [ -d "./${ASSETS_DIR}" ]; then log_info "检测到离线资源目录，优先使用离线模式。"; fi

    install_bash
    install_binaries
    install_vim

    log_info "所有任务完成！请运行 'source ~/.bashrc' 生效。"
}

main "$@"
