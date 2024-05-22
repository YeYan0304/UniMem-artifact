#!/bin/bash

MAX_FILE_SIZE=$1

    #Generate memory access sequence of pagerank 
    cd apps/turi/
    ./app_graph_analytics.py -g twitter -a pagerank &
    sleep 20s
    pid_pagerank=$!
    while :; do
        if [ ! kill -0 $pid_pagerank 2>/dev/null ]; then
            break
        else
            FILE_SIZE=$(stat -c%s "pinatrace.out")
            if [ "$FILE_SIZE" -gt "$MAX_FILE_SIZE" ];then
                kill -9 $pid_pagerank
                sleep 1s
                if ! kill -0 $pid_pagerank 2>/dev/null; then
                    break
                fi
            fi
            sleep 1s
        fi
    done
    mkdir ../../../src/Pagerank
    mv pinatrace.out ../../../src/Pagerank/pagerank.out

    #Generate memory access sequence of linear_regression
    cd ../metis
    ../../pintool/pin -t ../../pintool/source/tools/ManualExamples/obj-intel64/pinatrace.so -- ./Metis/obj/linear_regression ./Metis/data/lr_40GB.txt -p 8 &
    # ../../pintool/pin -t ../../pintool/source/tools/ManualExamples/obj-intel64/pinatrace.so -- ./Metis/obj/linear_regression ./Metis/data/lr_10MB.txt -p 8 &
    sleep 20s
    pid_pin=$!
    while :; do
        if [ ! kill -0 $pid_pin 2>/dev/null ]; then
            break
        else
            FILE_SIZE=$(stat -c%s "pinatrace.out")
            if [ "$FILE_SIZE" -gt "$MAX_FILE_SIZE" ];then
                kill -9 $pid_pin
                sleep 1s
                if ! kill -0 $pid_pin 2>/dev/null; then
                    break
                fi
            fi
            sleep 1s
        fi
    done
    
    mkdir ../../../src/Metis
    mv pinatrace.out ../../../src/Metis/metis.out
    cd ../../


    tmux new-session -d -s session1 
    tmux new-session -d -s session2
    sleep 2s

    #Generate memory access sequence of YCSB-A
    tmux send-keys -t session1 'cd YCSB/' C-m
    tmux send-keys -t session2 'cd YCSB/' C-m
    tmux send-keys -t session1 '../apps/redis/redis/src/redis-server ../apps/redis/redis/redis.conf' C-m
    sleep 2s
    pid_redis=$(pidof redis-server)
    echo "----------------redis pid="$pid_redis" workload="YCSB-A""
    # modify recordcount and operationcount in YCSB/workloads/workloada for workingset size (200000 in our evaluation)
    sed -i "s/"recordcount=[0-9]*"/"recordcount=200000"/" ./YCSB/workloads/workloada
    sed -i "s/"operationcount=[0-9]*"/"operationcount=200000"/" ./YCSB/workloads/workloada
    sleep 1s
    tmux send-keys -t session2 './bin/ycsb load redis -s -P ./workloads/workloada -p "redis.host=127.0.0.1" -p "redis.port=6379"' C-m
    tmux send-keys -t session2 '../pintool/pin -pid '$pid_redis' -t ../pintool/source/tools/ManualExamples/obj-intel64/pinatrace.so' C-m
    # A redis.clients.jedis.exceptions.JedisConnectionException: java.net.SocketTimeoutException: Read timed out error may occur.
    # When this error occurs, you may need to rerun the program several times.
    tmux send-keys -t session2 './bin/ycsb run redis -s -P ./workloads/workloada -p "redis.host=127.0.0.1" -p "redis.port=6379"' C-m

    tmux send-keys -t session2 'wait' C-m
    tmux send-keys -t session2 'mkdir ../../src/YCSB-A' C-m
    tmux send-keys -t session2 'mv pinatrace.out ../../src/YCSB-A/ycsb_a.out' C-m
    tmux send-keys -t session2 'kill '$pid_redis'' C-m
    sleep 20s
    while :; do
        pid_redis=$(pidof redis-server)
        if [[ -z $pid_redis ]]; then
            echo "continue..."
            break
        else
            FILE_SIZE=$(stat -c%s "./YCSB/pinatrace.out")
            if [ "$FILE_SIZE" -gt "$MAX_FILE_SIZE" ];then
                kill -9 $pid_redis
            fi
            sleep 1s
        fi
    done

    #Generate memory access sequence of YCSB-B
    tmux send-keys -t session1 '../apps/redis/redis/src/redis-server ../apps/redis/redis/redis.conf' C-m
    sleep 2s
    pid_redis=$(pidof redis-server)
    echo "----------------redis pid="$pid_redis" workload="YCSB-B""
    # modify recordcount and operationcount in YCSB/workloads/workloadb for workingset size (200000 in our evaluation)
    sed -i "s/"recordcount=[0-9]*"/"recordcount=200000"/" ./YCSB/workloads/workloadb
    sed -i "s/"operationcount=[0-9]*"/"operationcount=200000"/" ./YCSB/workloads/workloadb
    sleep 1s
    tmux send-keys -t session2 './bin/ycsb load redis -s -P ./workloads/workloadb -p "redis.host=127.0.0.1" -p "redis.port=6379"' C-m
    tmux send-keys -t session2 '../pintool/pin -pid '$pid_redis' -t ../pintool/source/tools/ManualExamples/obj-intel64/pinatrace.so' C-m
    # A redis.clients.jedis.exceptions.JedisConnectionException: java.net.SocketTimeoutException: Read timed out error may occur.
    # When this error occurs, you may need to rerun the program several times.
    tmux send-keys -t session2 './bin/ycsb run redis -s -P ./workloads/workloadb -p "redis.host=127.0.0.1" -p "redis.port=6379"' C-m

    tmux send-keys -t session2 'wait' C-m
    tmux send-keys -t session2 'mkdir ../../src/YCSB-B' C-m
    tmux send-keys -t session2 'mv pinatrace.out ../../src/YCSB-B/ycsb_b.out' C-m
    tmux send-keys -t session2 'kill '$pid_redis'' C-m
    sleep 20s
    while :; do
        pid_redis=$(pidof redis-server)
        if [[ -z $pid_redis ]]; then
            echo "continue..."
            break
        else
            FILE_SIZE=$(stat -c%s "./YCSB/pinatrace.out")
            if [ "$FILE_SIZE" -gt "$MAX_FILE_SIZE" ];then
                kill -9 $pid_redis
            fi
            sleep 1s
        fi
    done

    tmux send-keys -t session1 'cd ../' C-m
    tmux send-keys -t session2 'cd ../' C-m

    #Generate memory access sequence of Facebook-ETC
    tmux send-keys -t session1 'memcached -m 20480 -u root' C-m
    sleep 2s
    pid_memcached=$(pidof memcached | cut -d' ' -f1)
    echo "----------------memcached="$pid_memcached" workload="Memcached""

    tmux send-keys -t session2 './pintool/pin -pid '$pid_memcached' -t ./pintool/source/tools/ManualExamples/obj-intel64/pinatrace.so &' C-m
    tmux send-keys -t session2 './mutilate/mutilate -s '127.0.0.1:11211' -K 'gev:30.7984,8.20449,0.078688' -i 'pareto:0.0,16.0292,0.154971' -r 50000000 -u 1 &' C-m
    # tmux send-keys -t session2 './mutilate/mutilate -s '127.0.0.1:11211' -K 'gev:30.7984,8.20449,0.078688' -i 'pareto:0.0,16.0292,0.154971' -r 500 -u 1 &' C-m

    tmux send-keys -t session2 'wait' C-m
    tmux send-keys -t session2 'mkdir ../src/Memcache' C-m
    tmux send-keys -t session2 'mv pinatrace.out ../src/Memcache/memcache.out' C-m
    tmux send-keys -t session2 'kill '$pid_memcached'' C-m
    sleep 20s
    while :; do
        FILE_SIZE=$(stat -c%s "pinatrace.out")
        if [ "$FILE_SIZE" -gt "$MAX_FILE_SIZE" ];then
            kill -9 $pid_memcached
            sleep 1s
            if ! kill -0 $pid_memcached 2>/dev/null; then
                kill -9 $(pidof mutilate | cut -d' ' -f1)
                break
            fi
        fi
        sleep 1s
    done

    #Generate memory access sequence of Redis
    tmux send-keys -t session1 './apps/redis/redis/src/redis-server ./apps/redis/redis/redis.conf' C-m
    sleep 2s
    pid_redis=$(pidof redis-server)
    echo "----------------redis pid="$pid_redis" workload="Redis Rand""

    tmux send-keys -t session2 './pintool/pin -pid '$pid_redis' -t ./pintool/source/tools/ManualExamples/obj-intel64/pinatrace.so &' C-m
    tmux send-keys -t session2 'memtier_benchmark -p 6379 -t 10 -n 40000000 --ratio 1:1 -c 20 -x 1 --key-pattern R:R --hide-histogram --distinct-client-seed -d 300 --pipeline=1000 &' C-m
    # tmux send-keys -t session2 'memtier_benchmark -p 6379 -t 10 -n 100 --ratio 1:1 -c 20 -x 1 --key-pattern R:R --hide-histogram --distinct-client-seed -d 300 --pipeline=1000 &' C-m

    tmux send-keys -t session2 'wait' C-m
    tmux send-keys -t session2 'mkdir ../src/Redis' C-m
    tmux send-keys -t session2 'mv pinatrace.out ../src/Redis/redis.out' C-m
    tmux send-keys -t session2 'kill '$pid_redis'' C-m
    sleep 20s
    while :; do
        pid_redis=$(pidof redis-server)
        if [[ -z $pid_redis ]]; then
            echo "continue..."
            break
        else
            FILE_SIZE=$(stat -c%s "pinatrace.out")
            if [ "$FILE_SIZE" -gt "$MAX_FILE_SIZE" ];then
                kill -9 $pid_redis
            fi
            sleep 1s
        fi
    done

    sleep 1s
    current_session=$(tmux display-message -p '#S')
    tmux kill-session -t "$current_session"
    current_session=$(tmux display-message -p '#S')
    tmux kill-session -t "$current_session"