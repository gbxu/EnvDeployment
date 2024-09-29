# set -v

apt update && apt install zip pciutils ethtool hwloc -y

lstopo --of pdf cpu_topology.pdf
lscpu >> info.txt
lspci -vv >> info.txt
nvidia-smi topo -m >> info.txt
nvidia-smi nvlink -s
nvidia-smi >> info.txt
ethtool eth0 >> info.txt
hostname >> info.txt
env >> info.txt
