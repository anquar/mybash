#!/bin/bash

# This shell script is used for issue a Let'sEncrypt Cert And installation more convenitenly

# Some constans here
CERT_DOMAIN=''
ONLY_INSTALL_CERT=''
CERT_DEFAULT_INSTALL_PATH='/root/cert/'

# Some basic settings here
plain='\033[0m'
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'

function LOGD() {
    echo -e "${yellow}[DEG] $* ${plain}"
}

function LOGE() {
    echo -e "${red}[ERR] $* ${plain}"
}

function LOGI() {
    echo -e "${green}[INF] $* ${plain}"
}

# function for user choice
confirm() {
    if [[ $# > 1 ]]; then
        echo && read -p "$1 [默认$2]: " temp
        if [[ x"${temp}" == x"" ]]; then
            temp=$2
        fi
    else
        read -p "$1 [y/n]: " temp
    fi
    if [[ x"${temp}" == x"y" || x"${temp}" == x"Y" ]]; then
        return 0
    else
        return 1
    fi
}

# function for array contain
contain() {
    narr=($1)
    if [[ x"${narr}" == x"" ]]; then
        return 0
    else
        for i in "${narr[@]}"
        do
            if [ $i == $2 ]; then
                return 0
            fi
        done
    fi
    return 1
}

# Check whether you are root
LOGI "权限检查..."
currentUser=$(whoami)
LOGD "当前用户为 $currentUser"
if [ $currentUser != "root" ]; then
    LOGE "$Attention:请检查是否为root用户, please check whether you are root"
    exit 1
fi

install_acme() {
    cd ~
    if [ -x ~/.acme.sh/acme.sh ]; then
        LOGI "正在升级acme ..."
        ~/.acme.sh/acme.sh --upgrade
    else
        LOGI "开始安装acme脚本..."
        curl https://get.acme.sh | sh
        if [ $? -ne 0 ]; then
            LOGE "acme安装失败"
            return 1
        else
            LOGI "acme安装成功"
        fi
    fi
    return 0
}

set_cert_install_path() {
    cd ~
    local InstallPath=''
    read -p "请输入证书安装路径:" InstallPath
    if [[ -n ${InstallPath} ]]; then
        LOGD "你输入的路径为:${InstallPath}"
    else
        InstallPath=${CERT_DEFAULT_INSTALL_PATH}
        LOGI "输入路径为空,将采用默认路径:${CERT_DEFAULT_INSTALL_PATH}"
    fi

    InstallPath="${InstallPath}/${CERT_DOMAIN}"

    if [ ! -d "${InstallPath}" ]; then
        mkdir -p "${InstallPath}"
    else
        rm -rf "${InstallPath}"
        mkdir -p "${InstallPath}"
    fi

    if [ $? -ne 0 ]; then
        LOGE "设置安装路径失败,请确认"
        exit 1
    fi
    CERT_DEFAULT_INSTALL_PATH=${InstallPath}
}

set_cert_domain() {
    local domain=""
    read -p "请输入你的根域名:" domain
    LOGD "你输入的域名为:${domain},正在进行域名合法性校验..."
    # here we need to judge whether there exists cert already
    local currentCerts=($(~/.acme.sh/acme.sh --list | tail -n +2 | awk '{print $1}'))
    contain "${currentCerts[*]}" "${domain}"
    if [ $? -eq 0 ]; then
        local certInfo=$(~/.acme.sh/acme.sh --list)
        LOGI "当前环境已有对应域名证书,不可重复申请,当前证书详情:"
        LOGI "$certInfo"
        confirm "是否继续进行证书安装[y/n]" "n"
        if [ $? -ne 0 ]; then
            LOGI "脚本退出..."
            exit 1
        else
            LOGI "继续安装证书..."
            ONLY_INSTALL_CERT="true"
            CERT_DOMAIN=${domain}
        fi
    else
        LOGI "域名合法性校验通过..."
        CERT_DOMAIN=${domain}
    fi
}

set_cloudflare_dns_api() {
    local CF_GlobalKey=''
    local CF_AccountEmail=''
    read -p "请输入你的CF秘钥:" CF_GlobalKey
    LOGD "你的API密钥为:${CF_GlobalKey}"
    read -p "请输入你的CF邮箱:" CF_AccountEmail
    LOGD "你的注册邮箱为:${CF_AccountEmail}"
    export CF_Key="${CF_GlobalKey}"
    export CF_Email=${CF_AccountEmail}
}

ssl_cert_issue_by_cloudflare() {
    echo -E ""
    LOGI "该脚本将使用Acme脚本申请证书,使用时需保证:"
    LOGI "1.知晓Cloudflare注册邮箱"
    LOGI "2.知晓Cloudflare Global API Key"
    LOGI "3.根域名已通过Cloudflare进行解析到当前服务器"
    confirm "我已确认以上内容[y/n]" "y"
    if [ $? -eq 0 ]; then
        install_acme
        if [ $? -ne 0 ]; then
            LOGE "无法安装acme,请检查错误日志"
            exit 1
        fi

        set_cert_domain

        set_cert_install_path

        if [ ! -n "${ONLY_INSTALL_CERT}" ]; then
            if [ -n "$CF_Email" -a -n "$CF_Key" ]; then
                LOGI "Cloudflare邮箱和秘钥环境变量已设置"
                LOGI "邮箱: $CF_Email"
                LOGI "秘钥: $CF_Key"
                confirm "我要重新设置[y/n]" "n"
                if [ $? -ne 0 ]; then
                    set_cloudflare_dns_api
                fi
            else
                set_cloudflare_dns_api
            fi

            ~/.acme.sh/acme.sh --set-default-ca --server letsencrypt
            if [ $? -ne 0 ]; then
                LOGE "修改默认CA为Lets'Encrypt失败,脚本退出"
                exit 1
            fi
            ~/.acme.sh/acme.sh --issue --dns dns_cf -d ${CERT_DOMAIN} -d *.${CERT_DOMAIN} --log
            if [ $? -ne 0 ]; then
                LOGE "证书签发失败,脚本退出"
                exit 1
            else
                LOGI "证书签发成功,安装中..."
            fi
        fi

        confirm "是否自动重载nginx配置[y/n]" "n"
        if [ $? -eq 0 ]; then
            ~/.acme.sh/acme.sh --installcert -d ${CERT_DOMAIN} -d *.${CERT_DOMAIN} \
            --ca-file ${CERT_DEFAULT_INSTALL_PATH}/ca.cer \
            --cert-file ${CERT_DEFAULT_INSTALL_PATH}/${CERT_DOMAIN}.cer \
            --key-file ${CERT_DEFAULT_INSTALL_PATH}/${CERT_DOMAIN}.key \
            --fullchain-file ${CERT_DEFAULT_INSTALL_PATH}/fullchain.cer \
            --reloadcmd "systemctl reload nginx"
        else
            ~/.acme.sh/acme.sh --installcert -d ${CERT_DOMAIN} -d *.${CERT_DOMAIN} \
            --ca-file ${CERT_DEFAULT_INSTALL_PATH}/ca.cer \
            --cert-file ${CERT_DEFAULT_INSTALL_PATH}/${CERT_DOMAIN}.cer \
            --key-file ${CERT_DEFAULT_INSTALL_PATH}/${CERT_DOMAIN}.key \
            --fullchain-file ${CERT_DEFAULT_INSTALL_PATH}/fullchain.cer
        fi
        if [ $? -ne 0 ]; then
            LOGE "证书安装失败,脚本退出"
            exit 1
        else
            LOGI "证书安装成功,开启自动更新..."
        fi
        ~/.acme.sh/acme.sh --upgrade --auto-upgrade
        if [ $? -ne 0 ]; then
            LOGE "自动更新设置失败,脚本退出"
            ls -lah cert
            chmod 755 ${CERT_DEFAULT_INSTALL_PATH}
            exit 1
        else
            LOGI "证书已安装且已开启自动更新,具体信息如下"
            ls -lah ${CERT_DEFAULT_INSTALL_PATH}
            chmod 755 ${CERT_DEFAULT_INSTALL_PATH}
        fi
    else
        LOGI "脚本退出..."
        exit 1
    fi
}

ssl_cert_issue_by_cloudflare
