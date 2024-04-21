#!/bin/bash

# debian-12-init.sh
# 初始化Debian 12系统脚本
# wget -O debian-12-init.sh "https://raw.githubusercontent.com/chingwl/one-config/master/debian/debian-12-init.sh"
# chmod +x ./debian-12-init.sh
# ./debian-12-init.sh

# 修改软件源
change_source() {
    echo "请选择软件源："
    echo "1. 官方镜像源"
    echo "2. 阿里云镜像源"
    echo "3. 阿里云镜像源-内网"
    read -p "请输入你的选择（1-3）: " source_choice

    echo "备份当前的sources.list文件"
    mv /etc/apt/sources.list /etc/apt/sources.list.bak.$(date +%Y%m%d%H%M%S)
    echo "当前的sources.list文件备份完毕"

    case $source_choice in
    1)
        echo "正在设置官方镜像源..."
        echo "deb http://deb.debian.org/debian/ bookworm main non-free-firmware
              deb-src http://deb.debian.org/debian/ bookworm main non-free-firmware

              deb http://security.debian.org/debian-security bookworm-security main non-free-firmware
              deb-src http://security.debian.org/debian-security bookworm-security main non-free-firmware

              deb http://deb.debian.org/debian/ bookworm-updates main non-free-firmware
              deb-src http://deb.debian.org/debian/ bookworm-updates main non-free-firmware" | tee /etc/apt/sources.list
        echo "官方镜像源设置完毕..."
        ;;
    2)
        echo "正在设置阿里云镜像源..."
        echo "deb https://mirrors.aliyun.com/debian/ bookworm main non-free-firmware
              deb-src https://mirrors.aliyun.com/debian/ bookworm main non-free-firmware

              deb https://mirrors.aliyun.com/debian-security/ bookworm-security main non-free-firmware
              deb-src https://mirrors.aliyun.com/debian-security/ bookworm-security main non-free-firmware

              deb https://mirrors.aliyun.com/debian/ bookworm-updates main non-free-firmware
              deb-src https://mirrors.aliyun.com/debian/ bookworm-updates main non-free-firmware" | tee /etc/apt/sources.list
        echo "阿里云镜像源设置完毕..."
        ;;
    3)
        echo "正在设置阿里云镜像源-内网..."
        echo "deb http://mirrors.cloud.aliyuncs.com/debian bookworm main non-free-firmware
              deb-src http://mirrors.cloud.aliyuncs.com/debian bookworm main non-free-firmware

              deb http://mirrors.cloud.aliyuncs.com/debian-security bookworm-security main non-free-firmware
              deb-src http://mirrors.cloud.aliyuncs.com/debian-security bookworm-security main non-free-firmware

              deb http://mirrors.cloud.aliyuncs.com/debian bookworm-updates main non-free-firmware
              deb-src http://mirrors.cloud.aliyuncs.com/debian bookworm-updates main non-free-firmware" | tee /etc/apt/sources.list
        echo "阿里云-内网镜像源设置完毕..."
        ;;
    0 | *) ;;
    esac
}

# 更新软件包
update_packages() {
    echo "正在更新软件包..."
    apt update && apt upgrade -y
    echo "软件包更新完成。"
}

# 安装常用软件
install_common_software() {
    echo "正在安装常用软件..."
    apt install -y vim git curl wget sudo locales-all
    echo "常用软件安装完成。"
}

# SSH配置
config_ssh() {
    echo "配置SSH..."

    echo "备份当前的 /etc/ssh/sshd_config 文件..."
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak.$(date +%Y%m%d%H%M%S)
    echo "当前的 /etc/ssh/sshd_config 文件备份完毕..."

    read -p "请输入自定义的SSH端口号: " SSH_PORT

    SSHD_CONFIG="/etc/ssh/sshd_config"

    sed -i 's/^#?\s*Port .*/Port $SSH_PORT/' $SSHD_CONFIG
    sed -i 's/^#?\s*PermitRootLogin .*/PermitRootLogin no/' $SSHD_CONFIG
    sed -i 's/^#?\s*PasswordAuthentication .*/PasswordAuthentication no/' $SSHD_CONFIG
    sed -i 's/^#?\s*ClientAliveInterval .*/ClientAliveInterval 60/' $SSHD_CONFIG
    sed -i 's/^#?\s*ClientAliveCountMax .*/ClientAliveCountMax 60/' $SSHD_CONFIG

    echo "开始重启SSH服务..."
    /etc/init.d/ssh restart
    echo "重启SSH服务完成..."

    echo "SSH配置完成。"
}

# 配置历史命令自动补全功能
config_autocomplete() {
    echo "配置历史命令自动补全..."

    echo "备份当前的 /etc/inputrc 文件..."
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak.$(date +%Y%m%d%H%M%S)
    echo "当前的 /etc/inputrc 文件备份完毕..."

    echo '"\e[A": history-search-backward' | tee -a /etc/inputrc
    echo '"\e[B": history-search-forward' | tee -a /etc/inputrc

    echo "自动补全配置完成。"
}

# 创建新用户并配置
create_user() {
    read -p "请输入新用户名: " USER_NAME

    adduser $USER_NAME
    usermod -aG sudo $USER_NAME

    echo "备份当前的 /etc/sudoers 文件..."
    cp /etc/sudoers /etc/sudoers.bak.$(date +%Y%m%d%H%M%S)
    echo "当前的 /etc/sudoers 文件备份完毕..."

    echo "$USER_NAME    ALL=(ALL:ALL) NOPASSWD:ALL" | tee -a /etc/sudoers

    # 配置新用户系统语言为中文
    sudo -u $USER_NAME bash -c "$(declare -f config_locale); config_locale"

    # 配置新用户.bashrc文件
    sudo -u $USER_NAME bash -c "$(declare -f config_bashrc); config_bashrc"

    # 给新用户配置vim
    sudo -u $USER_NAME bash -c "$(declare -f config_vim); config_vim"

    echo "新用户$USER_NAME创建并配置完成。"
}

# 配置新用户系统语言为中文
config_locale() {
    echo "配置系统语言为中文..."
    sudo update-locale LANG=zh_CN.UTF-8
    echo "系统语言配置为中文完成。"
}

# 配置新用户.bashrc文件
config_bashrc() {

    echo "备份当前的 ~/.bashrc 文件..."
    cp ~/.bashrc ~/.bashrc.bak.$(date +%Y%m%d%H%M%S)
    echo "当前的 ~/.bashrc 文件备份完毕..."

    echo "alias ll='ls -l'" >> ~/.bashrc
    echo ".bashrc文件配置完成。"
}

# 给新用户配置vim
config_vim() {

    echo "备份当前的 ~/.vimrc 文件..."
    cp ~/.vimrc ~/.vimrc.bak.$(date +%Y%m%d%H%M%S)
    echo "当前的 ~/.vimrc 文件备份完毕..."

    echo "配置vim..."
    wget -O ~/.vimrc "https://raw.githubusercontent.com/chingwl/one-config/master/vim/.vimrc"
    echo "vim配置完成。"
}

# 主函数
main() {

    # 系统级别设置
    change_source
    update_packages
    install_common_software
    config_ssh
    config_autocomplete

    # 创建新用户
    create_user

    echo "所有初始化步骤已完成。"
}

# 执行主函数
main
