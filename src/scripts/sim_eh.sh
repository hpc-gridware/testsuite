#!/bin/sh

if [ $# -lt 1 ]; then
   echo "usage: $0 <num_addresses>"
   exit 1
fi

num_addresses=$1

IP_A=10
IP_B=`seq 1 254`
IP_C=`seq 1 254`
IP_D=`seq 1 254`

num=0
done=0
echo "# =============================================================================="
echo "# $num_addresses simulated execution hosts for Cluster Scheduler"
for a in $IP_A; do
   for b in $IP_B; do
      for c in $IP_C; do
         for d in $IP_D; do
            if [ $num -ge $num_addresses ]; then
               done=1
               break
            fi
            echo "$a.$b.$c.$d sim-eh-$a-$b-$c-$d"
            num=`expr $num + 1`
         done
         if [ $done -eq 1 ]; then
            break
         fi
      done
      if [ $done -eq 1 ]; then
         break
      fi
   done
   if [ $done -eq 1 ]; then
      break
   fi
done
echo "# =============================================================================="
