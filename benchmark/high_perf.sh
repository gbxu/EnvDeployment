#!/bin/bash

cpupower frequency-set -g performance # 设置CPU频率
opensm -B -g 0xa088c203006c1de4 # 启动opensm服务并绑定不同guid
opensm -B -g 0xa088c203006c1d04
mount 10.0.0.1:/nfs /nfs
modprobe nvidia-peermem # 加载内核模块用于gdr
nvidia-smi -pm 1 # 使用nvidia-smi命令启用NVIDIA GPU的持久模式
