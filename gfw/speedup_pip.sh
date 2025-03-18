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

# 测量延迟
USTC_DELAY=$(ping -c 4 pypi.tuna.tsinghua.edu.cn | tail -1| awk '{print $4}' | cut -d '/' -f 2)

# 测量延迟
ALIYUN_DELAY=$(ping -c 4 mirrors.aliyun.com | tail -1| awk '{print $4}' | cut -d '/' -f 2)

echo "USTC延迟: $USTC_DELAY ms"
echo "Aliyun延迟: $ALIYUN_DELAY ms"

# 比较延迟并选择更低的一个
if (( $(echo "$USTC_DELAY < $ALIYUN_DELAY" |bc -l) )); then
  echo "选择USTC镜像"
  echo -e "[global]\n\
timeout = 6000\n\
index-url = https://pypi.tuna.tsinghua.edu.cn/simple\n\
[install]\n\
trusted-host = pypi.tuna.tsinghua.edu.cn\n" > ~/.pip/pip.conf
  echo -e "[global]\n\
timeout = 6000\n\
index-url = https://pypi.tuna.tsinghua.edu.cn/simple\n\
[install]\n\
trusted-host = pypi.tuna.tsinghua.edu.cn\n" > /usr/pip.conf
else
  echo "选择Aliyun镜像"
  echo -e "[global]\n\
timeout = 6000\n\
index-url = https://mirrors.aliyun.com/pypi/simple\n\
[install]\n\
trusted-host = mirrors.aliyun.com\n" > ~/.pip/pip.conf
  echo -e "[global]\n\
timeout = 6000\n\
index-url = https://mirrors.aliyun.com/pypi/simple\n\
[install]\n\
trusted-host = mirrors.aliyun.com\n" > /usr/pip.conf
fi
