#!/bin/bash
if [[ "$(whoami)" != "root" ]]; then
    SUDO=sudo
fi

# docker

# ib
# install MLNX_OFED for system
wget --quiet http://content.mellanox.com/ofed/MLNX_OFED-5.0-1.0.0.0/MLNX_OFED_LINUX-5.0-1.0.0.0-ubuntu20.04-x86_64.tgz
tar -xvf MLNX_OFED_LINUX-5.0-1.0.0.0-ubuntu20.04-x86_64.tgz
sudo MLNX_OFED_LINUX-5.0-1.0.0.0-ubuntu20.04-x86_64/mlnxofedinstall --user-space-only --without-fw-update --all --force

# pyenv

# conda
