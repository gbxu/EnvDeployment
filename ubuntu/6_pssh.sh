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
ensure_command_installed parallel-ssh pssh

HOSTFILE="/tmp/hostfile.txt"
echo "192.168.1.1" > ${HOSTFILE}
echo "192.168.1.2" >> ${HOSTFILE}

REMOTE_HOME="${HOME}" # /root/
USE_PASSWD="-A"
NO_CHECK='-x "-o StrictHostKeyChecking=no"'
CMD="ls"
TIMEOUT="-t 0"

parallel-ssh -i -h ${HOSTFILE} ${USE_PASSWD} ${NO_CHECK}  ${TIMEOUT} "${CMD}"
parallel-scp -r -h ${HOSTFILE} .ssh ${REMOTE_HOME}
