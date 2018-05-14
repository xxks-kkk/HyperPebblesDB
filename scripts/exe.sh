echo start > surf_and_bloom.txt
echo bloom >> surf_and_bloom.txt
./.libs/db_bench --benchmarks=fillseq,readseq,readreverse,readrandom,scanrandom --num=10000000 --reads=4000000  >> surf_and_bloom.txt 
sleep 200
echo surf >> surf_and_bloom.txt
./.libs/db_bench --benchmarks=fillseq,readseq,readreverse,readrandom,scanrandom --num=10000000 --reads=4000000 --bloom_bits=-1 >> surf_and_bloom.txt
sleep 200
echo bloom >> surf_and_bloom.txt
./.libs/db_bench --benchmarks=fillseq,readseq,readreverse,readrandom,scanrandom --num=10000000 --reads=4000000  >> surf_and_bloom.txt 
sleep 200
echo surf >> surf_and_bloom.txt
./.libs/db_bench --benchmarks=fillseq,readseq,readreverse,readrandom,scanrandom --num=10000000 --reads=4000000 --bloom_bits=-1 >> surf_and_bloom.txt
