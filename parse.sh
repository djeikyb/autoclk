#!/usr/bin/env bash

IFS=$'\n'
lines=($(cat))

audit_date=${lines[0]:24:8}
audit_time=${lines[0]:33:8}

for line in ${lines[6]} ${lines[7]} ${lines[8]} ${lines[9]} ${lines[10]}
do
    day=${line:5:8}
    time_in=${line:14:5}
    time_out=${line:22:5}
    hours=${line:32:5}
    pcd=${line:41:8}

    echo "$audit_date,$audit_time,$day,$time_in,$time_out,$hours,$pcd"
done
