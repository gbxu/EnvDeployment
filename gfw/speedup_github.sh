#!/bin/bash
if [[ "$(whoami)" != "root" ]]; then
    SUDO=sudo
fi

# GitHub相关域名
GITHUB_DOMAINS=(
    "github.com"
    "raw.githubusercontent.com"
    "github.global.ssl.fastly.net"
)

# 备份/etc/hosts文件
${SUDO} cp /etc/hosts /etc/hosts.backup
# 删除/etc/hosts中现有的GitHub域名条目
for domain in "${GITHUB_DOMAINS[@]}"; do
    ${SUDO} sed -i "/$domain/d" /etc/hosts
done

# 查询并更新每个域名的IP地址
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
    else
        # 其他Linux系统可能需要重启网络服务
        ${SUDO} /etc/init.d/networking restart
    fi
else
    echo "Unsupported OS: $OS"
fiecho "GitHub hosts update complete."
