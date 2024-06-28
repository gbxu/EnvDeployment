GPUTYPE=`nvidia-smi -q -i 0 | grep "Product Name" |awk -F ': ' '{print $2}'`
export GPUS_PER_NODE=`nvidia-smi -q -i 0 | grep "Attached GPUs" |awk -F ': ' '{print $2}'`

if [ "${GPUTYPE}" = "GeForce GTX 1080 Ti" ]; then
    export CLUSTER="ADSL"
elif [ "${GPUTYPE}" = "Tesla V100-PCIE-16GB" ]; then
    export CLUSTER="AZURE-V100-16GB"
else
    export CLUSTER="AZURE-V100-32GB"
fi

if [ "${CLUSTER}" = "AZURE-V100-32GB" ]; then
    export NIC=ib0 && export DRIVER=mlx5
    export NODES=2
    export PROC=worker-0:${GPUS_PER_NODE}
    for ((i=1; i<$NODES; i++))
    do
        PROC=$PROC,worker-$i:${GPUS_PER_NODE}
    done
elif [ "${CLUSTER}" = "AZURE-V100-16GB" ]; then
    export NIC=ib0 && export DRIVER=mlx4
    export NODES=4
    export PROC=worker-0:${GPUS_PER_NODE}
    for ((i=1; i<$NODES; i++))
    do
        PROC=$PROC,worker-$i:${GPUS_PER_NODE}
    done
else
    export NIC=ib0 && export DRIVER=mlx4
    export NODES=2
    ########## ADSL ##########
    export PROC=10.0.0.42:${GPUS_PER_NODE},10.0.0.44:${GPUS_PER_NODE}
fi
export PROC_SIZE=$(($GPUS_PER_NODE*$NODES))



export LD_LIBRARY_PATH=${HOME}/nccl/build/lib:$LD_LIBRARY_PATH
for OP in "all_gather_perf"  "all_reduce_perf"  "alltoall_perf"  "broadcast_perf"  "hypercube_perf"  "reduce_perf"  "reduce_scatter_perf"  "scatter_perf"  "sendrecv_perf"
do
    LOG_PATH=${HOME}/network-speed/$OP
    cmd="--allow-run-as-root -H $PROC -np $PROC_SIZE -mca -bind-to none -map-by slot -mca pml ob1 -mca btl ^openib -mca btl_tcp_if_include $NIC -tag-output -merge-stderr-to-stdout -output-filename ${LOG_PATH} -x PATH -x LD_LIBRARY_PATH -x PYTHONPATH -x NCCL_SOCKET_IFNAME=$NIC  -x NCCL_IB_DISABLE=0 -x NCCL_DEBUG=INFO -x NCCL_DEBUG_SUBSYS=ALL -x NCCL_IB_HCA=$DRIVER -x NCCL_P2P_DISABLE=0 -x NCCL_IB_CUDA_SUPPORT=1 ${HOME}/nccl-tests/build/$OP -b 1K -e 128M -f 2 -g 1"
    if [ "${CLUSTER}" = "ADSL" ]; then
        mpirun -mca plm_rsh_args "-p 12445" ${cmd}
    else
        mpirun ${cmd}
    fi
done
