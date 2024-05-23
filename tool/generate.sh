#!/bin/bash
arg=$1

    ./pagerank.sh $arg
    sleep 2s
    ./linear_regression.sh $arg
    sleep 2s
    ./redis.sh $arg
    sleep 2s
    ./Memcached.sh $arg
    sleep 2s
    ./YCSB_A.sh $arg
    sleep 2s
    ./YCSB_B.sh $arg
    sleep 2s 
