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
