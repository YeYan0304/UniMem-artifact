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
    mkdir ../../../src/Metis
    mv pinatrace.out ../../../src/Metis/metis.out
    cd ../../

    #Generate memory access sequence of YCSB-A and YCSB-B
    cd YCSB/
    ../apps/redis/redis/src/redis-server ../apps/redis/redis/redis.conf & pid_redis=$!
    echo "----------------redis pid="$pid_redis" workload="YCSB-A""
    sleep 2s
    ./bin/ycsb load redis -s -P ./workloads/workloada -p "redis.host=127.0.0.1" -p "redis.port=6379"
    ../pintool/pin -pid $pid_redis -t ../pintool/source/tools/ManualExamples/obj-intel64/pinatrace.so
    echo "----------------bef run"
    ./bin/ycsb run redis -s -P ./workloads/workloada -p "redis.host=127.0.0.1" -p "redis.port=6379"
    kill $pid_redis
    mkdir ../../src/YCSB-A
    mv pinatrace.out ../../src/YCSB-A/ycsb_a.out

    ../apps/redis/redis/src/redis-server ../apps/redis/redis/redis.conf & pid_redis=$!
    echo "----------------redis pid="$pid_redis" workload="YCSB-B""
    sleep 2s
    ./bin/ycsb load redis -s -P ./workloads/workloadb -p "redis.host=127.0.0.1" -p "redis.port=6379"
    ../pintool/pin -pid $pid_redis -t ../pintool/source/tools/ManualExamples/obj-intel64/pinatrace.so
    echo "----------------bef run"
    ./bin/ycsb run redis -s -P ./workloads/workloadb -p "redis.host=127.0.0.1" -p "redis.port=6379"
    kill $pid_redis
    mkdir ../../src/YCSB-B
    mv pinatrace.out ../../src/YCSB-B/ycsb_b.out
    cd ../

    #Generate memory access sequence of Memcached
    memcached -m 20480 -u root & pid_redis=$!
    echo "----------------redis pid="$pid_redis" workload="Memcached""
    sleep 2s
    ./pintool/pin -pid $pid_redis -t ./pintool/source/tools/ManualExamples/obj-intel64/pinatrace.so
    echo "----------------bef run"
    ./mutilate/mutilate -s '127.0.0.1:11211' -K 'gev:30.7984,8.20449,0.078688' -i 'pareto:0.0,16.0292,0.154971' -r 500000 -u 1
    #./mutilate/mutilate -s '127.0.0.1:11211' -K 'gev:30.7984,8.20449,0.078688' -i 'pareto:0.0,16.0292,0.154971' -r 500 -u 1
    kill $pid_redis
    mkdir ../src/Memcache
    mv pinatrace.out ../src/Memcache/memcache.out

    ./apps/redis/redis/src/redis-server ./apps/redis/redis/redis.conf & pid_redis=$!
    echo "----------------redis pid="$pid_redis" workload="Redis Rand""
    sleep 2s
    ./pintool/pin -pid $pid_redis -t ./pintool/source/tools/ManualExamples/obj-intel64/pinatrace.so
    memtier_benchmark -p 6379 -t 10 -n 400000 --ratio 1:1 -c 20 -x 1 --key-pattern R:R --hide-histogram --distinct-client-seed -d 300 --pipeline=1000
    #memtier_benchmark -p 6379 -t 10 -n 400 --ratio 1:1 -c 20 -x 1 --key-pattern R:R --hide-histogram --distinct-client-seed -d 300 --pipeline=1000
    kill $pid_redis
    mkdir ../src/Redis
    mv pinatrace.out ../src/Redis/redis.out


