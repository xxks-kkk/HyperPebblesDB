# Run YCSB on top of Mongo-Rocks and Mongo-Pebbles

iteration=0;
YCSB=/home/jianwei/vm/mongo/ycsb-0.5.0/bin/ycsb 
MONGO=/home/jianwei/vm/mongo/mongodb-linux-x86_64-ubuntu1604-3.6.3/bin/mongo
MAX_ITER=5
RECORD_CNT=5000000
OP_CNT=1000000
SLEEP_TIME=300
if [ -f ~/vm/mongo/ycsb-0.5.0/run.txt ]; then
    rm ~/vm/mongo/ycsb-0.5.0/run.txt
fi
if [ -f ~/vm/mongo/ycsb-0.5.0/load.txt ]; then
    rm ~/vm/mongo/ycsb-0.5.0/load.txt
fi
while (($iteration<$MAX_ITER));
do
echo "workloada" >> load.txt 
$YCSB load mongodb -s -P workloads/workloada -p recordcount=$RECORD_CNT -threads 8 | tail -n 30 >> load.txt
sleep $SLEEP_TIME

echo "workloada" >> run.txt
$YCSB run  mongodb -s -P workloads/workloada -p recordcount=$RECORD_CNT -p operationcount=$OP_CNT -threads 8 | tail -n 30 >> run.txt
sleep $SLEEP_TIME

echo "workloadb" >> run.txt
$YCSB run  mongodb -s -P workloads/workloadb -p recordcount=$RECORD_CNT -p operationcount=$OP_CNT -threads 8 | tail -n 30 >> run.txt
sleep $SLEEP_TIME

echo "workloadc" >> run.txt
$YCSB run  mongodb -s -P workloads/workloadc -p recordcount=$RECORD_CNT -p operationcount=$OP_CNT -threads 8 | tail -n 30 >> run.txt
sleep $SLEEP_TIME

echo "workloadf" >> run.txt
$YCSB run  mongodb -s -P workloads/workloadf -p recordcount=$RECORD_CNT -p operationcount=$OP_CNT -threads 8 | tail -n 30 >> run.txt
sleep $SLEEP_TIME


echo "workloadd" >> run.txt
$YCSB run  mongodb -s -P workloads/workloadd -p recordcount=$RECORD_CNT -p operationcount=$OP_CNT -threads 8 | tail -n 30 >> run.txt
sleep $SLEEP_TIME



$MONGO --eval 'db = db.getSiblingDB("ycsb"); db.dropDatabase()'
sleep $SLEEP_TIME


echo "workloade" >> load.txt
$YCSB load mongodb -s -P workloads/workloade -p recordcount=$RECORD_CNT -threads 8 | tail -n 30 >> load.txt
sleep $SLEEP_TIME

echo "workloade" >> run.txt
$YCSB run  mongodb -s -P workloads/workloade -p recordcount=$RECORD_CNT -p operationcount=$OP_CNT -threads 8 | tail -n 30 >> run.txt
sleep $SLEEP_TIME

$MONGO --eval 'db = db.getSiblingDB("ycsb"); db.dropDatabase()'

((iteration=$iteration+1));
done;

