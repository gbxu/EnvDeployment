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
ensure_command_installed ping inetutils-ping

# 测量 mirrors.ustc.edu.cn 的平均延迟
USTC_DELAY=$(ping -c 4 mirrors.ustc.edu.cn | tail -1| awk '{print $4}' | cut -d '/' -f 2)

# 测量 mirrors.aliyun.com 的平均延迟
ALIYUN_DELAY=$(ping -c 4 mirrors.aliyun.com | tail -1| awk '{print $4}' | cut -d '/' -f 2)

echo "USTC延迟: $USTC_DELAY ms"
echo "Aliyun延迟: $ALIYUN_DELAY ms"

# 比较延迟并选择更低的一个
ensure_command_installed bc
if (( $(echo "$USTC_DELAY < $ALIYUN_DELAY" |bc -l) )); then
  echo "选择USTC镜像"
  ${SUDO} sed -i 's/archive.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list
else
  echo "选择Aliyun镜像"
  ${SUDO} sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list
fi
