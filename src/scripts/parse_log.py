import subprocess
import sys
import csv
log_file = sys.argv[1]
result = subprocess.check_output("grep 'Compaction level' {} -A 3".format(log_file), shell=True)
entries = result.split("--\n")

with open(log_file + "_res.csv", "w") as f:
    writer = csv.writer(f)
    writer.writerow(["level", "guards", "file_num", "file_size", "time"])
    for entry in entries:
        print(entry)
        lines = entry.split("\n")
        level = lines[0].split(' ')[-1]
        file_size = int(lines[1].split(' ')[5]) + int(lines[2].split(' ')[5])
        file_num = int(lines[1].split(' ')[3]) + int(lines[2].split(' ')[3])
        guards = int(lines[1].split(' ')[7])
        micros = lines[3].split(' ')[-2]
        writer.writerow([level, guards, file_num, file_size, micros])
        print([level, guards, file_num, file_size, micros])
