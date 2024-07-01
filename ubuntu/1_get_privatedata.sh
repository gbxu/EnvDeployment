#!/bin/bash
THIS_PATH=$(readlink -f "$0")
THIS_DIR=$(dirname "$THIS_PATH")
MY_ENV_DEPLOYMENT=${THIS_DIR}/../../EnvDeployment
source ${MY_ENV_DEPLOYMENT}/configs/.my_aliases
echo "MY_ENV_DEPLOYMENT is located at: ${MY_ENV_DEPLOYMENT}"
if [[ "$(whoami)" != "root" ]]; then
    SUDO=sudo
fi
export DEBIAN_FRONTEND=noninteractive

if [ ! -d ${MY_ENV_DEPLOYMENT}/privatedata ]; then
    if [ -f "${HOME}/.ssh/id_rsa" ]; then
        cd ${MY_ENV_DEPLOYMENT}
        git submodule update --init --recursive
    else
        project_key_dir="${MY_ENV_DEPLOYMENT}/privatedata/.ssh"
        if [ -f "${MY_ENV_DEPLOYMENT}/privatedata/.ssh/id_rsa" ]; then
            cp ${MY_ENV_DEPLOYMENT}/privatedata/.ssh ${MY_ENV_DEPLOYMENT}/privatedata/.ssh.backup
            mkdir -p ${project_key_dir}
            ssh-keygen -t rsa -b 4096 -f "${project_key_dir}/id_rsa" -N "new project key"
            echo "generate a pair of new key: ${project_key_dir}."
            cat ${project_key_dir}/id_rsa.pub >> ${MY_ENV_DEPLOYMENT}/configs/.ssh/authorized_keys
        fi
    fi
else
    echo "${MY_ENV_DEPLOYMENT}/privatedata exists"
fi
