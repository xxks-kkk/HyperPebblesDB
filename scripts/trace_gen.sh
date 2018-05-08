TRACE_DIR=traces
WORKLOAD_DIR=./YCSB/workloads
mkdir -p $TRACE_DIR
RECORDCNT=1000000
OPCNT=200000

./YCSB/bin/ycsb.sh load kvtracer -P $WORKLOAD_DIR/workloada -p "kvtracer.tracefile=$TRACE_DIR/tracea_load.txt" -p recordcount=$RECORDCNT -p operationcount=$OPCNT -p "kvtracer.keymapfile=$TRACE_DIR/tracea_keys.txt"
./YCSB/bin/ycsb.sh run kvtracer -P $WORKLOAD_DIR/workloada -p "kvtracer.tracefile=$TRACE_DIR/tracea_run.txt" -p recordcount=$RECORDCNT -p operationcount=$OPCNT   -p "kvtracer.keymapfile=$TRACE_DIR/tracea_keys.txt"
./YCSB/bin/ycsb.sh run kvtracer -P $WORKLOAD_DIR/workloadb -p "kvtracer.tracefile=$TRACE_DIR/traceb_run.txt" -p recordcount=$RECORDCNT -p operationcount=$OPCNT   -p "kvtracer.keymapfile=$TRACE_DIR/tracea_keys.txt"
./YCSB/bin/ycsb.sh run kvtracer -P $WORKLOAD_DIR/workloadc -p "kvtracer.tracefile=$TRACE_DIR/tracec_run.txt" -p recordcount=$RECORDCNT -p operationcount=$OPCNT   -p "kvtracer.keymapfile=$TRACE_DIR/tracea_keys.txt"
./YCSB/bin/ycsb.sh run kvtracer -P $WORKLOAD_DIR/workloadf -p "kvtracer.tracefile=$TRACE_DIR/tracef_run.txt" -p recordcount=$RECORDCNT -p operationcount=$OPCNT   -p "kvtracer.keymapfile=$TRACE_DIR/tracea_keys.txt"
./YCSB/bin/ycsb.sh run kvtracer -P $WORKLOAD_DIR/workloadd -p "kvtracer.tracefile=$TRACE_DIR/traced_run.txt" -p recordcount=$RECORDCNT -p operationcount=$OPCNT   -p "kvtracer.keymapfile=$TRACE_DIR/tracea_keys.txt"

./YCSB/bin/ycsb.sh load kvtracer -P $WORKLOAD_DIR/workloade -p "kvtracer.tracefile=$TRACE_DIR/tracee_load.txt" -p recordcount=$RECORDCNT -p operationcount=$OPCNT -p "kvtracer.keymapfile=$TRACE_DIR/tracee_keys.txt"
./YCSB/bin/ycsb.sh run kvtracer -P $WORKLOAD_DIR/workloade -p "kvtracer.tracefile=$TRACE_DIR/tracee_run.txt" -p recordcount=$RECORDCNT -p operationcount=$OPCNT   -p "kvtracer.keymapfile=$TRACE_DIR/tracee_keys.txt"
