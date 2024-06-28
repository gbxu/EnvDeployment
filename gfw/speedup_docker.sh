#!/bin/bash

if [[ "$(whoami)" != "root" ]]; then
    SUDO=sudo
fi

${SUDO} mkdir -p /etc/docker
${sudo} tee /etc/docker/daemon.json <<EOF
{
    "registry-mirrors": [
        "https://docker.mirrors.ustc.edu.cn",
        "https://docker.nju.edu.cn"
    ]
}
EOF
${sudo} systemctl daemon-reload
${sudo} systemctl restart docker

