#!/bin/bash
THIS_PATH=$(readlink -f "$0")
THIS_DIR=$(dirname "$THIS_PATH")
MY_ENV_DEPLOYMENT=${THIS_DIR}/../../EnvDeployment
if [[ "$(whoami)" != "root" ]]; then
    SUDO=sudo
fi

command_exists() {
  command -v "$@" >/dev/null 2>&1
}

# Check if parallel-ssh is installed, if not, install it
if ! command_exists parallel-ssh; then
    echo "parallel-ssh not found, installing..."
    ${SUDO} apt update && ${SUDO} apt install -y pssh
fi

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
