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

# 使用 ed 命令修改 /etc/resolv.conf 文件，最开始增加 8.8.8.8
ensure_command_installed ed
${SUDO} ed -s /etc/resolv.conf <<EOF
0a
nameserver 8.8.8.8
.
w
q
EOF

# GitHub相关域名
GITHUB_DOMAINS=(
    "github.com"
    "raw.githubusercontent.com"
    "github.global.ssl.fastly.net"
)

# 备份/etc/hosts文件
${SUDO} cp /etc/hosts /etc/hosts.backup
temp_file=$(mktemp)
# 将/etc/hosts的内容复制到临时文件中
${SUDO} cp /etc/hosts "$temp_file"
for domain in "${GITHUB_DOMAINS[@]}"; do
    # 使用sed命令在临时文件上就地编辑，移除匹配的域名
    ${SUDO} sed -i "/${domain}/d" "$temp_file"
done
# 将修改后的临时文件内容复制回/etc/hosts
${SUDO} cat "$temp_file" > /etc/hosts
# 删除临时文件
rm "$temp_file"

# 查询并更新每个域名的IP地址
ensure_command_installed dig dnsutils
ensure_command_installed ping inetutils-ping
ensure_command_installed bc bc
for domain in "${GITHUB_DOMAINS[@]}"; do
    # 使用dig命令查询域名的所有IP地址
    ips=($(dig +short $domain))
    min_latency=99999
    selected_ip=""

    for ip in "${ips[@]}"; do
        # 测试每个IP的延迟，取平均值
        latency=$(ping -c 4 $ip | tail -1| awk '{print $4}' | cut -d '/' -f 2)
        if [[ $latency != "" && $(echo "$latency < $min_latency" | bc) -eq 1 ]]; then
            min_latency=$latency
            selected_ip=$ip
        fi
    done

    if [[ -n "$selected_ip" ]]; then
        # 添加延迟最低的IP地址
        echo "Adding $domain with IP $selected_ip to /etc/hosts"
        echo "$selected_ip $domain" | ${SUDO} tee -a /etc/hosts > /dev/null
    else
        echo "IP address for $domain not found or ping failed"
    fi
done

# 判断操作系统并刷新DNS缓存
OS=$(uname -s)
if [ "$OS" = "Darwin" ]; then
    ${SUDO} dscacheutil -flushcache # macOS系统
elif [ "$OS" = "Linux" ]; then
    # 假设Linux系统为Ubuntu或类似Debian的系统
    # 检查systemd-resolve是否可用（Ubuntu 16.04及更高版本）
    if command -v systemd-resolve &> /dev/null; then
        ${SUDO} systemd-resolve --flush-caches
    elif command -v resolvconf &> /dev/null; then
        # 对于一些使用resolvconf的系统
        ${SUDO} resolvconf -u
    elif command -v nmcli &> /dev/null; then
        # 对于使用NetworkManager的系统
        ${SUDO} nmcli general reload
    else
        echo "No known method to flush DNS cache on this system."
    fi
else
    echo "Unsupported OS: $OS"
fi
echo "GitHub hosts update complete."
