#!/bin/bash

if [[ "$(whoami)" != "root" ]]; then
    SUDO=sudo
fi

${SUDO} apt update
${SUDO} apt install zip pssh -y
