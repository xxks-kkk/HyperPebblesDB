#!/bin/sh -vx

# Try to replicate the experiement "Impact of Empty Guards" in PebblesDB paper
max_iter=20
i=0

WORKLOADS=${1:-0}

case $WORKLOADS in
    0)
        benchmarks_args=fillseq,readrandom,seekrandom,deleteseq,stats,emptyGuards
        ;;
    1)
        benchmarks_args=fillseq,readreverse,seekrandom,deleteseq,stats,emptyGuards
        ;;
    2)
        benchmarks_args=fillseq,readmissing,seekrandom,deleteseq,stats,emptyGuards
        ;;
    3)
        benchmarks_args=fillseq,readhot,seekrandom,deleteseq,stats,emptyGuards
        ;;
    4)
        benchmarks_args=fillrandom,readseq,readrandom,readreverse,readmissing,readhot,seekrandom,stats,emptyGuards
        ;;
    *)
        ;;
esac

db_path=/var/local/pebblesdbtest-1000
num=100000000
value_size=512
reads=50000000

# We insert 20M key-value pairs (with keys from 0 to 20M, value size: 512B, dataset size: 10 GB), perform 10M read operations on the data, and delete all keys.
./db_bench --benchmarks=$benchmarks_args --num=$num --value_size=$value_size --reads=$reads --base_key=0 --db=$db_path
du -sh $db_path

# We then repeat this, but with keys from 20M to 40M.
while [ $i -lt $max_iter ]
do
    ./db_bench --benchmarks=$benchmarks_args --num=$num --value_size=$value_size --reads=$reads --base_key=$(( ($i+1)*100 )) --db=$db_path --use_existing_db=1
    du -sh $db_path
    i=$(( $i + 1 ))
done

