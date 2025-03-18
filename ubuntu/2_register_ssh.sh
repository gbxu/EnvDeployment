#!/bin/bash
THIS_PATH=$(readlink -f "$0")
THIS_DIR=$(dirname "$THIS_PATH")
MY_ENV_DEPLOYMENT=${THIS_DIR}/../../EnvDeployment
if [[ "$(whoami)" != "root" ]]; then
    SUDO=sudo
fi

if [ -d "${HOME}/.ssh" ]; then
    echo "${HOME}/.ssh exists."
    # 复制认证
    echo "Register your authorized_keys to ${HOME}/.ssh/authorized_keys"
    if [ -f "${HOME}/.ssh/authorized_keys" ]; then
        cat ${MY_ENV_DEPLOYMENT}/configs/.ssh/authorized_keys >> ${HOME}/.ssh/authorized_keys
    else
        cp ${MY_ENV_DEPLOYMENT}/configs/.ssh/authorized_keys ${HOME}/.ssh/
    fi
    # 复制公钥
    if [ ! -f "${HOME}/.ssh/id_rsa.pub" ]; then
        echo "Register your id_rsa.pub to ${HOME}/.ssh/id_rsa.pub"
        cp ${MY_ENV_DEPLOYMENT}/configs/.ssh/id_rsa.pub ${HOME}/.ssh/
    else
        echo "${HOME}/.ssh/id_rsa.pub exists."
    fi
    # 复制配置
    if [ ! -f "${HOME}/.ssh/config" ]; then
        echo "Register your config to ${HOME}/.ssh/config"
        cp ${MY_ENV_DEPLOYMENT}/configs/.ssh/config ${HOME}/.ssh/
    else
        echo "${HOME}/.ssh/config exists."
    fi
else
    # 复制整个文件夹
    echo "Register your .ssh to ${HOME}/.ssh"
    cp -r ${MY_ENV_DEPLOYMENT}/configs/.ssh ${HOME}/.ssh
fi

chmod 700 ${HOME}/.ssh
chmod 600 ${HOME}/.ssh/authorized_keys
chmod 644 ${HOME}/.ssh/id_rsa.pub

# 复制私钥
if [ ! -f "${HOME}/.ssh/id_rsa" ]; then
    echo "Register your id_rsa to ${HOME}/.ssh/id_rsa"
    cp ${MY_ENV_DEPLOYMENT}/privatedata/.ssh/id_rsa ${HOME}/.ssh/
else
    echo "${HOME}/.ssh/id_rsa exists."
fi
chmod 600 ${HOME}/.ssh/id_rsa
