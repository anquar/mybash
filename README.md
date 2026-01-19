# Setup Bash Environment

这是一个集成了 Bash 和 Vim 高效配置的自动化脚本，旨在通过单个脚本快速构建舒适的终端开发环境。

## ✨ 主要功能

* **Bash 环境增强**：
    * 基于 **Oh My Bash**，默认使用 `powerbash10k` 主题。
    * 集成实用插件：`git`, `zoxide` (智能目录跳转), `fzf` (模糊搜索), `colored-man-pages` 等。
    * 内置实用别名和函数（如网络测速、IP 查询等）。
* **Vim 深度配置**：
    * 自动化配置 `.vimrc`，开箱即用。
    * 集成 **vim-plug** 插件管理器。
    * 预装精选插件：`NERDTree` (文件树), `FZF` (文件搜索), `Lightline` (状态栏), `GitGutter` (Git 状态), `Easymotion` (快速跳转) 等。
    * 默认使用 `Catppuccin Mocha` 主题。
* **现代工具集成**：
    * 自动安装 **fd** (比 find 更快更友好的查找工具)。
    * 自动安装 **ripgrep (rg)** (超快的代码搜索工具)。
* **灵活的安装模式**：
    * 支持 **交互式安装** (默认) 和 **静默安装** (无人值守)。
    * 支持 **在线安装** 和 **完全离线安装**。
* **一键卸载**：
    * 支持完全卸载并还原之前的配置文件。

## 🚀 快速开始

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/anquar/mybash/main/setup-bash.sh)
```

或者

### 1. 下载脚本
将 `setup-bash.sh` 保存到本地：

```bash
# 假设你已经有了脚本文件
chmod +x setup-bash.sh
```

### 2. 标准安装 (在线)

直接运行脚本，按照提示选择是否安装各个组件：

```bash
./setup-bash.sh
```

### 3. 静默安装

默认回答所有问题为 "Yes"，适合自动化部署：

```bash
./setup-bash.sh -s
# 或
./setup-bash.sh --silent
```

安装完成后，请运行 `source ~/.bashrc` 或重新登录终端以使配置生效。

## 📦 离线安装指南

本脚本支持在无网络环境（Air-gapped）下进行配置。

### 第一步：制作离线包 (在有网机器上)

使用 `-d` 参数下载所有依赖资源（Oh My Bash, Vim 插件, 二进制工具包等）：

```bash
./setup-bash.sh -d
```

执行后，脚本会在当前目录下生成一个名为 `bash-assets` 的文件夹，其中包含所有安装所需文件。

### 第二步：迁移与安装 (在无网机器上)

1. 将 `setup-bash.sh` 脚本 和 `bash-assets` 文件夹 复制到目标机器的同一目录下。

2. 运行安装脚本：

```bash
./setup-bash.sh
```

脚本会自动检测到 `bash-assets` 目录，并优先使用其中的资源进行安装，不会发起网络请求。

## 🗑️ 卸载与还原

如果你想移除本脚本配置的环境，可以使用卸载功能：

```bash
./setup-bash.sh -u
# 或
./setup-bash.sh --uninstall
```

卸载操作会执行以下清理：

- 删除 `~/.oh-my-bash` 目录。
- 删除 `~/.vim/plugged` 插件目录和 `plug.vim`。
- 删除 `~/.local/bin` 下安装的 `fd` 和 `rg` 二进制文件。
- 自动还原 之前的 `~/.bashrc` 和 `~/.vimrc` (如果有备份的话)。

## 🛠️ 命令参数说明

| 参数 | 长参数      | 描述                                                |
| ---- | ----------- | --------------------------------------------------- |
| -h   | --help      | 显示帮助信息                                        |
| -s   | --silent    | 静默模式：不询问用户，默认安装所有组件              |
| -d   | -download   | 下载模式：仅下载资源到 bash-assets 目录，不进行安装 |
| -u   | --uninstall | 移除配置环境并尝试还原备份                          |
