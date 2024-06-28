#!/bin/bash

jump_forward_port=${1:-60003} # 跳板机额外增加一个端口
local_service_port=${2:-22} # 本地服务的端口
jump_user=${3:-${USER}} # 跳板机的登录设置，可以在~/.ssh/config中配置
jump_host=${4:-pita}
jump_ssh_port=${5:-22}
local_monitoring_port=${6:-0} # 默认为0，不使用额外端口来保持存活

if dpkg -l | grep -qw autossh; then
  echo "autossh already installed."
else
  echo "autossh not installed, try to install it."
  apt update
  apt install -y autossh
fi

# 让跳板机把jump_forward_port的流量映射到本地服务监听的local_service_port 。 例如 autossh -M 0 -f -NT -D 54321:localhost:22 pita
autossh -p ${jump_ssh_port} -M ${local_monitoring_port} -fTN -R ${jump_forward_port}:localhost:${local_service_port} ${jump_user}@${jump_host}
# 本地创建socks代理，监听local_proxy_port 流量动态转发到跳板机。 例如autossh -M 0 -f -NT -D localhost:7891 pita
autossh -p ${jump_ssh_port} -M ${local_monitoring_port} -fTN -D localhost:${local_service_port} ${jump_user}@${jump_host}

sleep 6h
