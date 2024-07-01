#!/bin/bash
set -x
THIS_PATH=$(readlink -f "$0")
THIS_DIR=$(dirname "$THIS_PATH")
MY_ENV_DEPLOYMENT=${THIS_DIR}/../../EnvDeployment
if [[ "$(whoami)" != "root" ]]; then
    SUDO=sudo
fi

if [ -d "${HOME}/.ssh" ]; then
    echo "${HOME}/.ssh exists."
    # 复制认证
    if [ -f "${HOME}/.ssh/authorized_keys" ]; then
        cat ${MY_ENV_DEPLOYMENT}/configs/.ssh/authorized_keys >> ${HOME}/.ssh/authorized_keys
    else
        cp ${MY_ENV_DEPLOYMENT}/configs/.ssh/authorized_keys ${HOME}/.ssh/
    fi
    # 复制公钥
    if [ ! -f "${HOME}/.ssh/id_rsa.pub" ]; then
        cp ${MY_ENV_DEPLOYMENT}/configs/.ssh/id_rsa.pub ${HOME}/.ssh/
    fi
    # 复制配置
    if [ ! -f "${HOME}/.ssh/config" ]; then
        cp ${MY_ENV_DEPLOYMENT}/configs/.ssh/config ${HOME}/.ssh/
    fi
else
    # 复制整个文件夹
    cp -r ${MY_ENV_DEPLOYMENT}/configs/.ssh ${HOME}/.ssh
fi

chmod 700 ${HOME}/.ssh
chmod 600 ${HOME}/.ssh/authorized_keys
chmod 644 ${HOME}/.ssh/id_rsa.pub

# 复制私钥
if [ ! -f "${HOME}/.ssh/id_rsa" ]; then
    cp ${MY_ENV_DEPLOYMENT}/privatedata/.ssh/id_rsa ${HOME}/.ssh/
fi
chmod 600 ${HOME}/.ssh/id_rsa
