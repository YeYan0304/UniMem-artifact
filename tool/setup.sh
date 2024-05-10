#!/bin/bash
pid_redis=0

    #download pintool
    wget https://software.intel.com/sites/landingpage/pintool/downloads/pin-3.30-98830-g1d7b601b3-gcc-linux.tar.gz
    tar -xzf pin-3.30-98830-g1d7b601b3-gcc-linux.tar.gz
    mv pin-3.30-98830-g1d7b601b3-gcc-linux pintool
    rm pin-3.30-98830-g1d7b601b3-gcc-linux.tar.gz
    # copy pinatrace.cpp
    cp source/pinatrace.cpp pintool/source/tools/ManualExamples/
    cd pintool/source/tools/ManualExamples/
    make obj-intel64/pinatrace.so TARGET=intel64
    cd ../../../../

    #download YCSB
    git clone http://github.com/brianfrankcooper/YCSB.git
    cd YCSB
    mvn -pl site.ycsb:redis-binding -am clean package
    cd ../

    #download mutilate
    git clone https://github.com/leverich/mutilate.git
    apt-get install scons libevent-dev gengetopt libzmq-dev
    cd mutilate/
    scons
    cd ../

    #download apps
    git clone https://github.com/project-kona/apps.git  
    cd apps/turi/
    #download Twitter-dataset
    wget https://archive.org/download/asu_twitter_dataset/Twitter-dataset.zip
    unzip Twitter-dataset.zip
    # copy app_graph_analytic.py
    cp ../../source/app_graph_analytics.py app_graph_analytics.py
    chmod +x app_graph_analytics.py
    cd ../scripts
    sudo ./setup.sh

    #Generate memory access sequence of pagerank 
    cd ../turi/
    ./app_graph_analytics.py -g twitter -a pagerank
    mkdir ../../../src/Pagerank
    mv pinatrace.out ../../../src/Pagerank/pagerank.out

    #Generate memory access sequence of metis
    cd ../metis
    ../../pintool/pin -t ../../pintool/source/tools/ManualExamples/obj-intel64/pinatrace.so -- ./Metis/obj/linear_regression ./Metis/data/lr_40GB.txt -p 8
    # ../../pintool/pin -t ../../pintool/source/tools/ManualExamples/obj-intel64/pinatrace.so -- ./Metis/obj/linear_regression ./Metis/data/lr_10MB.txt -p 8
    mkdir ../../../src/Metis
    mv pinatrace.out ../../../src/Metis/metis.out
    cd ../../

    tmux new-session -d -s session1 
    tmux new-session -d -s session2

    #Generate memory access sequence of YCSB-A and YCSB-B
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
    while :; do
        pid_redis=$(pidof redis-server)
        if [[ -z $pid_redis ]]; then
            echo "continue..."
            break
        else
            sleep 1s
        fi
    done

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
    while :; do
        pid_redis=$(pidof redis-server)
        if [[ -z $pid_redis ]]; then
            echo "continue..."
            break
        else
            sleep 1s
        fi
    done

    tmux send-keys -t session1 'cd ../' C-m
    tmux send-keys -t session2 'cd ../' C-m
    

    #Generate memory access sequence of Memcached
    tmux send-keys -t session1 'memcached -m 20480 -u root' C-m
    sleep 2s
    pid_redis=$(pidof memcached)
    echo "----------------memcached="$pid_redis" workload="Memcached""

    tmux send-keys -t session2 './pintool/pin -pid '$pid_redis' -t ./pintool/source/tools/ManualExamples/obj-intel64/pinatrace.so &' C-m
    tmux send-keys -t session2 './mutilate/mutilate -s '127.0.0.1:11211' -K 'gev:30.7984,8.20449,0.078688' -i 'pareto:0.0,16.0292,0.154971' -r 500000 -u 1' C-m
    # tmux send-keys -t session2 './mutilate/mutilate -s '127.0.0.1:11211' -K 'gev:30.7984,8.20449,0.078688' -i 'pareto:0.0,16.0292,0.154971' -r 500 -u 1' C-m

    tmux send-keys -t session2 'wait' C-m
    tmux send-keys -t session2 'mkdir ../src/Memcache' C-m
    tmux send-keys -t session2 'mv pinatrace.out ../src/Memcache/memcache.out' C-m
    tmux send-keys -t session2 'kill '$pid_redis'' C-m
    while :; do
        pid_redis=$(pidof redis-server)
        if [[ -z $pid_redis ]]; then
            echo "continue..."
            break
        else
            sleep 1s
        fi
    done

    #Generate memory access sequence of Redis
    tmux send-keys -t session1 './apps/redis/redis/src/redis-server ./apps/redis/redis/redis.conf' C-m
    sleep 2s
    pid_redis=$(pidof redis-server)
    echo "----------------redis pid="$pid_redis" workload="Redis Rand""

    tmux send-keys -t session2 './pintool/pin -pid '$pid_redis' -t ./pintool/source/tools/ManualExamples/obj-intel64/pinatrace.so &' C-m
    tmux send-keys -t session2 'memtier_benchmark -p 6379 -t 10 -n 400000 --ratio 1:1 -c 20 -x 1 --key-pattern R:R --hide-histogram --distinct-client-seed -d 300 --pipeline=1000 &' C-m
    # tmux send-keys -t session2 'memtier_benchmark -p 6379 -t 10 -n 100 --ratio 1:1 -c 20 -x 1 --key-pattern R:R --hide-histogram --distinct-client-seed -d 300 --pipeline=1000 &' C-m

    tmux send-keys -t session2 'wait' C-m
    tmux send-keys -t session2 'mkdir ../src/Redis' C-m
    tmux send-keys -t session2 'mv pinatrace.out ../src/Redis/redis.out' C-m
    tmux send-keys -t session2 'kill '$pid_redis'' C-m
    while :; do
        pid_redis=$(pidof redis-server)
        if [[ -z $pid_redis ]]; then
            echo "continue..."
            break
        else
            sleep 1s
        fi
    done

    sleep 1s
    current_session=$(tmux display-message -p '#S')
    tmux kill-session -t "$current_session"
    current_session=$(tmux display-message -p '#S')
    tmux kill-session -t "$current_session"
    echo "setup finished"
