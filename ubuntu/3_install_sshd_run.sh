#!/bin/bash
THIS_PATH=$(readlink -f "$0")
THIS_DIR=$(dirname "$THIS_PATH")
MY_ENV_DEPLOYMENT=${THIS_DIR}/../../EnvDeployment
if [[ "$(whoami)" != "root" ]]; then
    SUDO=sudo
fi
export DEBIAN_FRONTEND=noninteractive

${SUDO} apt update
${SUDO} apt install ssh -y
cp ${MY_ENV_DEPLOYMENT}/configs/.ssh/sshd_config /etc/ssh/sshd_config
${SUDO} service ssh start
