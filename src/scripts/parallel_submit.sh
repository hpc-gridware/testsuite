#!/usr/bin/env bash

jobs=$1
for i in $(seq 1 "$jobs"); do
  qsub -h -b y sleep &
done

# optionally wait for all qsub client processes to finish
wait
