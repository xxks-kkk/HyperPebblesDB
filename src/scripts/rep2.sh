#!/bin/sh -vx

# Try to replicate the experiement "Impact of Empty Guards" in PebblesDB paper
max_iter=19              # num of iterations to run
i=0         
num=1000000             # num rows to insert
value_size=512          # row size (byte)
reads=$(( $num / 2 ))   # num reads
db_bench=../db_bench    # path to db_bench executable

WORKLOADS=${1:-0}       # which workload to run
case $WORKLOADS in
    0)
        benchmarks_args=fillseq,readseq,seekrandom,deleteseq,stats,emptyGuards
        #benchmarks_args=fillseq,readseq,deleteseq,stats,emptyGuards        
        ;;
    1)
        benchmarks_args=fillseq,readrandom,seekrandom,deleteseq,stats,emptyGuards
        #benchmarks_args=fillseq,readrandom,deleteseq,stats,emptyGuards        
        ;;
    2)
        benchmarks_args=fillseq,readreverse,seekrandom,deleteseq,stats,emptyGuards
        #benchmarks_args=fillseq,readreverse,deleteseq,stats,emptyGuards        
        ;;
    3)
        benchmarks_args=fillseq,readmissing,seekrandom,deleteseq,stats,emptyGuards
        #benchmarks_args=fillseq,readmissing,deleteseq,stats,emptyGuards        
        ;;
    4)
        benchmarks_args=fillseq,readhot,seekrandom,deleteseq,stats,emptyGuards
        #benchmarks_args=fillseq,readhot,deleteseq,stats,emptyGuards        
        ;;
    5)
        benchmarks_args=fillrandom,readseq,readrandom,readreverse,readmissing,readhot,seekrandom,stats,emptyGuards
        #benchmarks_args=fillrandom,readseq,readrandom,readreverse,readmissing,readhot,stats,emptyGuards        
        ;;
    6)
        benchmarks_args=fillseq,readseq,readrandom,readreverse,readmissing,readhot,seekrandom,stats,emptyGuards
        #benchmarks_args=fillseq,readseq,readrandom,readreverse,readmissing,readhot,stats,emptyGuards        
        ;;    
    *)
        ;;
esac

db_path=./pebblesdbtest-1000
mkdir -p $db_path

echo "<Experiment $WORKLOADS>"

# We insert 20M key-value pairs (with keys from 0 to 20M, value size: 512B, dataset size: 10 GB), perform 10M read operations on the data, and delete all keys.
./$db_bench --benchmarks=$benchmarks_args --num=$num --value_size=$value_size --reads=$reads --base_key=0 --db=$db_path
du -sh $db_path

# We then repeat this, but with keys from 20M to 40M.
while [ $i -lt $max_iter ]
do
    ./$db_bench --benchmarks=$benchmarks_args --num=$num --value_size=$value_size --reads=$reads --base_key=$(( ($i+1)*100 )) --db=$db_path --use_existing_db=1
    du -sh $db_path
    i=$(( $i + 1 ))
done

