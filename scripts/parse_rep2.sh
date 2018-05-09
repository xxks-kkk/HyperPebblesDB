# Parse the typescript file generated by
# - rep2.sh
# - rep2_driver.sh
#
# $1 - which data: fillseq, fillrandom, readseq, readrandom, readreverse, readmissing, readhot, empty,
# $2 - location of typescript
#
# Assumption:
# - experiment number is corresponding with the benchmark workload number in rep2.sh
# - We only want micro/s number
echo $1
if [ "$1" = "fillseq" ]; then
    printf "exp 0\n"
    grep ^$1 $2 | awk '{ print $2}' | sed 's/:*0*//' | awk 'FNR >= 1 && FNR <= 20'
    printf "exp 1\n"
    grep ^$1 $2 | awk '{ print $2}' | sed 's/:*0*//' | awk 'FNR >= 21 && FNR <= 40'
    printf "exp 2\n"
    grep ^$1 $2 | awk '{ print $2}' | sed 's/:*0*//' | awk 'FNR >= 41 && FNR <= 60'
    printf "exp 3\n"
    grep ^$1 $2 | awk '{ print $2}' | sed 's/:*0*//' | awk 'FNR >= 61 && FNR <= 80'
    printf "exp 4\n"
    grep ^$1 $2 | awk '{ print $2}' | sed 's/:*0*//' | awk 'FNR >= 81 && FNR <= 100'    
elif [ "$1" = "fillrandom" ]; then
    printf "exp 5\n"
    grep ^$1 $2 | awk '{ print $2}' | sed 's/:*0*//'
elif [ "$1" = "readseq" ] \
        || [ "$1" = "readrandom" ] \
        || [ "$1" = "readreverse" ] \
        || [ "$1" = "readmissing" ] \
        || [ "$1" = "readhot" ]; then
    printf "exp 1\n"
    grep ^$1 $2 | awk '{ print $2}' | sed 's/:*0*o*//' | awk 'FNR >= 1 && FNR <= 20'
    printf "exp 5\n"
    grep ^$1 $2 | awk '{ print $2}' | sed 's/:*0*//' | awk 'FNR >= 21 && FNR <= 40'
elif [ "$1" = "empty" ]; then
    # we show empty guards fraction
    grep ^$1 $2 | awk '
        BEGIN{
          count = 0
          num = 0
        }
        { if (count % 21 == 0){
          printf "exp %d\n", num
          num++
          count = 1
          }  
          count++
          print $4
        }
        '
fi
       
    
