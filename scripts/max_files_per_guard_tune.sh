#!/bin/bash -vx

max_iter=5              # num of iterations to run
i=0         
num=100000             # num rows to insert
value_size=512          # row size (byte)
reads=$(( $num / 2 ))   # num reads
db_bench=../db_bench    # path to db_bench executable

WORKLOADS=${1:-0}       # which workload to run
case $WORKLOADS in
    0)
        benchmarks_args=fillseq,readseq,deleteseq,stats,emptyGuards,sstables
        ;;
    1)
        benchmarks_args=fillseq,readrandom,deleteseq,stats,emptyGuards,sstables
        ;;
    2)
        benchmarks_args=fillseq,readreverse,deleteseq,stats,emptyGuards        
        ;;
    3)
        benchmarks_args=fillseq,readmissing,deleteseq,stats,emptyGuards        
        ;;
    4)
        benchmarks_args=fillseq,readhot,deleteseq,stats,emptyGuards        
        ;;
    5)
        benchmarks_args=fillrandom,readseq,readrandom,readreverse,readmissing,readhot,stats,emptyGuards        
        ;;
    6)
        benchmarks_args=fillseq,readseq,readrandom,readreverse,readmissing,readhot,stats,emptyGuards        
        ;;    
    *)
        ;;
esac

db_path=./pebblesdbtest-1000
mkdir -p $db_path

repeat(){
# We insert 20M key-value pairs (with keys from 0 to 20M, value size: 512B, dataset size: 10 GB), perform 10M read operations on the data, and delete all keys.
./$db_bench --benchmarks=$benchmarks_args --num=$num --value_size=$value_size --reads=$reads --base_key=0 --db=$db_path
du -sh $db_path
sleep 300

# We then repeat this, but with keys from 20M to 40M.
while [ $i -lt $max_iter ]
do
    ./$db_bench --benchmarks=$benchmarks_args --num=$num --value_size=$value_size --reads=$reads --base_key=$(( ($i+1)*100 )) --db=$db_path --use_existing_db=1
    du -sh $db_path
    i=$(( $i + 1 ))
    sleep 300
done
}

build(){
cd ../
make db_bench
cd scripts
}

echo "<Experiment $WORKLOADS>"
try=0
max_tune=7
while [ $try -lt $max_tune ]
do
    try=$(( $try + 1 ))    
    echo "<PARALLEL>"
    echo "[max=$try]"
    if [ $try = 1 ]; then
	sed -i "s/static const unsigned kMaxFilesPerGuardSentinel = $(( $try + 1 ));/static const unsigned kMaxFilesPerGuardSentinel = $try;/" ../db/dbformat.h
    elif [ $try = 2 ]; then
	echo ""
    else
	sed -i "s/static const unsigned kMaxFilesPerGuardSentinel = $(( try - 1));/static const unsigned kMaxFilesPerGuardSentinel = $try;/" ../db/dbformat.h
    fi
    exit
    build
    repeat
    sed -i 's/parallel_guard_compaction(true)/parallel_guard_compaction(false)/' ../util/options.cc
    echo "<NO_PARALLEL>"
    repeat
    sed -i 's/parallel_guard_compaction(false)/parallel_guard_compaction(true)/' ../util/options.cc
    if [ $try = 1 ]; then
	sed -i "s/static const unsigned kMaxFilesPerGuardSentinel = 1;/static const unsigned kMaxFilesPerGuardSentinel = 2;/" ../db/dbformat.h
    fi
done
