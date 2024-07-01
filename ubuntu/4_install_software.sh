#!/bin/bash
if [[ "$(whoami)" != "root" ]]; then
    SUDO=sudo
fi
export DEBIAN_FRONTEND=noninteractive

${SUDO} apt update
${SUDO} apt install zip pssh xterm -y

