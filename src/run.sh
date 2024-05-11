#!/bin/bash

# Simulation Average Latency configurations(ns)
Address_translation_latency=14
Host_Memory_latency=80
Device_attached_Memory_latency=150
Remote_Memory_latency_512B=2000
Remote_Memory_latency_1KB=2500
Remote_Memory_latency_2KB=3000
Remote_Memory_latency_4KB=4000
Batch_Promote_latency=$(echo "scale=2; 1987 / 512" | bc)

    # generate cache miss sequence
    echo "start generate cache miss sequence..."
    g++ -g -o ./Memcache/l3-cache ./main/L3-Cache.cpp
    ./Memcache/l3-cache ./Memcache/memcache.out ./Memcache/memcache-cache_miss
    rm ./Memcache/l3-cache
    g++ -g -o ./Metis/l3-cache ./main/L3-Cache.cpp
    ./Metis/l3-cache ./Metis/metis.out ./Metis/metis-cache_miss
    rm ./Metis/l3-cache
    g++ -g -o ./Pagerank/l3-cache ./main/L3-Cache.cpp
    ./Pagerank/l3-cache ./Pagerank/pagerank.out ./Pagerank/pagerank-cache_miss
    rm ./Pagerank/l3-cache
    g++ -g -o ./Redis/l3-cache ./main/L3-Cache.cpp
    ./Redis/l3-cache ./Redis/redis.out ./Redis/redis-cache_miss
    rm ./Redis/l3-cache
    g++ -g -o ./YCSB-A/l3-cache ./main/L3-Cache.cpp
    ./YCSB-A/l3-cache ./YCSB-A/ycsb_a.out ./YCSB-A/ycsb_a-cache_miss
    rm ./YCSB-A/l3-cache
    g++ -g -o ./YCSB-B/l3-cache ./main/L3-Cache.cpp
    ./YCSB-B/l3-cache ./YCSB-B/ycsb_b.out ./YCSB-B/ycsb_b-cache_miss
    rm ./YCSB-B/l3-cache
    mkdir mix
    g++ -g -o ./mix/l3-cache ./main/L3-Cache-mix.cpp
    ./mix/l3-cache ./Redis/redis.out ./Memcache/memcache.out ./Pagerank/pagerank.out ./YCSB-A/ycsb_a.out ./mix/mix-cache_miss
    rm ./mix/l3-cache
    echo "cache miss sequence generated"

    # count the number of pages under different subpages
    echo "counting the number of pages under different subpages..."
    sed -i "5c #define SUBPAGE 0x7f" ./main/workload-PageCount.cpp
	g++ -g -o count-128 ./main/workload-PageCount.cpp
    sed -i "5c #define SUBPAGE 0xff" ./main/workload-PageCount.cpp
	g++ -g -o count-256 ./main/workload-PageCount.cpp
    sed -i "5c #define SUBPAGE 0x1ff" ./main/workload-PageCount.cpp
	g++ -g -o count-512 ./main/workload-PageCount.cpp
    sed -i "5c #define SUBPAGE 0x3ff" ./main/workload-PageCount.cpp
	g++ -g -o count-1k ./main/workload-PageCount.cpp
    sed -i "5c #define SUBPAGE 0x7ff" ./main/workload-PageCount.cpp
	g++ -g -o count-2k ./main/workload-PageCount.cpp
    sed -i "5c #define SUBPAGE 0xfff" ./main/workload-PageCount.cpp
	g++ -g -o count-4k ./main/workload-PageCount.cpp
    ./count-4k ./Metis/metis-cache_miss ./Metis/metis-count-4k
    ./count-512 ./Metis/metis-cache_miss ./Metis/metis-count-512
    ./count-4k ./YCSB-B/ycsb_b-cache_miss ./YCSB-B/ycsb_b-count-4k
    ./count-512 ./YCSB-B/ycsb_b-cache_miss ./YCSB-B/ycsb_b-count-512
    ./count-4k ./mix/mix-cache_miss ./mix/mix-count-4k
    ./count-512 ./mix/mix-cache_miss ./mix/mix-count-512
    ./count-128 ./Redis/redis-cache_miss ./Redis/redis-count-128
    ./count-256 ./Redis/redis-cache_miss ./Redis/redis-count-256
    ./count-512 ./Redis/redis-cache_miss ./Redis/redis-count-512
    ./count-1k ./Redis/redis-cache_miss ./Redis/redis-count-1k
    ./count-2k ./Redis/redis-cache_miss ./Redis/redis-count-2k
    ./count-4k ./Redis/redis-cache_miss ./Redis/redis-count-4k
    ./count-128 ./Memcache/memcache-cache_miss ./Memcache/memcache-count-128
    ./count-256 ./Memcache/memcache-cache_miss ./Memcache/memcache-count-256
    ./count-512 ./Memcache/memcache-cache_miss ./Memcache/memcache-count-512
    ./count-1k ./Memcache/memcache-cache_miss ./Memcache/memcache-count-1k
    ./count-2k ./Memcache/memcache-cache_miss ./Memcache/memcache-count-2k
    ./count-4k ./Memcache/memcache-cache_miss ./Memcache/memcache-count-4k
    ./count-128 ./Pagerank/pagerank-cache_miss ./Pagerank/pagerank-count-128
    ./count-256 ./Pagerank/pagerank-cache_miss ./Pagerank/pagerank-count-256
    ./count-512 ./Pagerank/pagerank-cache_miss ./Pagerank/pagerank-count-512
    ./count-1k ./Pagerank/pagerank-cache_miss ./Pagerank/pagerank-count-1k
    ./count-2k ./Pagerank/pagerank-cache_miss ./Pagerank/pagerank-count-2k
    ./count-4k ./Pagerank/pagerank-cache_miss ./Pagerank/pagerank-count-4k
    ./count-128 ./YCSB-A/ycsb_a-cache_miss ./YCSB-A/ycsb_a-count-128
    ./count-256 ./YCSB-A/ycsb_a-cache_miss ./YCSB-A/ycsb_a-count-256
    ./count-512 ./YCSB-A/ycsb_a-cache_miss ./YCSB-A/ycsb_a-count-512
    ./count-1k ./YCSB-A/ycsb_a-cache_miss ./YCSB-A/ycsb_a-count-1k
    ./count-2k ./YCSB-A/ycsb_a-cache_miss ./YCSB-A/ycsb_a-count-2k
    ./count-4k ./YCSB-A/ycsb_a-cache_miss ./YCSB-A/ycsb_a-count-4k
    rm count-*
    echo "counting the number of pages under different subpages finished"

    echo "run Facebook-ETC..." 
    cd Memcache
    second_line=$(sed -n '2p' memcache-count-128)
    memcache_128=$(echo "$second_line" | awk -F ':' '{print $2}' | tr -d '[:space:]')
    second_line=$(sed -n '2p' memcache-count-256)
    memcache_256=$(echo "$second_line" | awk -F ':' '{print $2}' | tr -d '[:space:]')
    second_line=$(sed -n '2p' memcache-count-512)
    memcache_512=$(echo "$second_line" | awk -F ':' '{print $2}' | tr -d '[:space:]')
    second_line=$(sed -n '2p' memcache-count-1k)
    memcache_1k=$(echo "$second_line" | awk -F ':' '{print $2}' | tr -d '[:space:]')
    second_line=$(sed -n '2p' memcache-count-2k)
    memcache_2k=$(echo "$second_line" | awk -F ':' '{print $2}' | tr -d '[:space:]')
    second_line=$(sed -n '2p' memcache-count-4k)
    memcache_4k=$(echo "$second_line" | awk -F ':' '{print $2}' | tr -d '[:space:]')
    ../main/run-Page-cache.sh memcache $memcache_4k
    ../main/run-Kona.sh memcache $memcache_4k
    ../main/run-Unimem.sh memcache $memcache_512
    ../main/run-Unimem-LRU-proportion.sh memcache $memcache_512
    ../main/run-Unimem-nopromote.sh memcache $memcache_512
    ../main/run-Unimem-set.sh memcache $memcache_512
    ../main/run-Unimem-subpage.sh memcache $memcache_128 $memcache_256 $memcache_1k $memcache_2k $memcache_4k
    rm bip-* fifo-* lru-*
    cd ../
    echo "Facebook-ETC finished" 

    echo "run Redis Rand..." 
    cd Redis
    second_line=$(sed -n '2p' redis-count-128)
    redis_128=$(echo "$second_line" | awk -F ':' '{print $2}' | tr -d '[:space:]')
    second_line=$(sed -n '2p' redis-count-256)
    redis_256=$(echo "$second_line" | awk -F ':' '{print $2}' | tr -d '[:space:]')
    second_line=$(sed -n '2p' redis-count-512)
    redis_512=$(echo "$second_line" | awk -F ':' '{print $2}' | tr -d '[:space:]')
    second_line=$(sed -n '2p' redis-count-1k)
    redis_1k=$(echo "$second_line" | awk -F ':' '{print $2}' | tr -d '[:space:]')
    second_line=$(sed -n '2p' redis-count-2k)
    redis_2k=$(echo "$second_line" | awk -F ':' '{print $2}' | tr -d '[:space:]')
    second_line=$(sed -n '2p' redis-count-4k)
    redis_4k=$(echo "$second_line" | awk -F ':' '{print $2}' | tr -d '[:space:]')
    ../main/run-Page-cache.sh redis $redis_4k
    ../main/run-Kona.sh redis $redis_4k
    ../main/run-Unimem.sh redis $redis_512
    ../main/run-Unimem-LRU-proportion.sh redis $redis_512
    ../main/run-Unimem-nopromote.sh redis $redis_512
    ../main/run-Unimem-set.sh redis $redis_512
    ../main/run-Unimem-subpage.sh redis $redis_128 $redis_256 $redis_1k $redis_2k $redis_4k
    rm bip-* fifo-* lru-*
    cd ../
    echo "Redis Rand finished"

    echo "run Page Rank..." 
    cd Pagerank
    second_line=$(sed -n '2p' pagerank-count-128)
    pagerank_128=$(echo "$second_line" | awk -F ':' '{print $2}' | tr -d '[:space:]')
    second_line=$(sed -n '2p' pagerank-count-256)
    pagerank_256=$(echo "$second_line" | awk -F ':' '{print $2}' | tr -d '[:space:]')
    second_line=$(sed -n '2p' pagerank-count-512)
    pagerank_512=$(echo "$second_line" | awk -F ':' '{print $2}' | tr -d '[:space:]')
    second_line=$(sed -n '2p' pagerank-count-1k)
    pagerank_1k=$(echo "$second_line" | awk -F ':' '{print $2}' | tr -d '[:space:]')
    second_line=$(sed -n '2p' pagerank-count-2k)
    pagerank_2k=$(echo "$second_line" | awk -F ':' '{print $2}' | tr -d '[:space:]')
    second_line=$(sed -n '2p' pagerank-count-4k)
    pagerank_4k=$(echo "$second_line" | awk -F ':' '{print $2}' | tr -d '[:space:]')
    ../main/run-Page-cache.sh pagerank $pagerank_4k
    ../main/run-Kona.sh pagerank $pagerank_4k
    ../main/run-Unimem.sh pagerank $pagerank_512
    ../main/run-Unimem-LRU-proportion.sh pagerank $pagerank_512
    ../main/run-Unimem-nopromote.sh pagerank $pagerank_512
    ../main/run-Unimem-set.sh pagerank $pagerank_512
    ../main/run-Unimem-subpage.sh pagerank $pagerank_128 $pagerank_256 $pagerank_1k $pagerank_2k $pagerank_4k
    rm bip-* fifo-* lru-*
    cd ../
    echo "Page Rank finished"

    echo "run YCSB-A..." 
    cd YCSB-A
    second_line=$(sed -n '2p' ycsb_a-count-128)
    ycsb_a_128=$(echo "$second_line" | awk -F ':' '{print $2}' | tr -d '[:space:]')
    second_line=$(sed -n '2p' ycsb_a-count-256)
    ycsb_a_256=$(echo "$second_line" | awk -F ':' '{print $2}' | tr -d '[:space:]')
    second_line=$(sed -n '2p' ycsb_a-count-512)
    ycsb_a_512=$(echo "$second_line" | awk -F ':' '{print $2}' | tr -d '[:space:]')
    second_line=$(sed -n '2p' ycsb_a-count-1k)
    ycsb_a_1k=$(echo "$second_line" | awk -F ':' '{print $2}' | tr -d '[:space:]')
    second_line=$(sed -n '2p' ycsb_a-count-2k)
    ycsb_a_2k=$(echo "$second_line" | awk -F ':' '{print $2}' | tr -d '[:space:]')
    second_line=$(sed -n '2p' ycsb_a-count-4k)
    ycsb_a_4k=$(echo "$second_line" | awk -F ':' '{print $2}' | tr -d '[:space:]')
    ../main/run-Page-cache.sh ycsb_a $ycsb_a_4k
    ../main/run-Kona.sh ycsb_a $ycsb_a_4k
    ../main/run-Unimem.sh ycsb_a $ycsb_a_512
    ../main/run-Unimem-LRU-proportion.sh ycsb_a $ycsb_a_512
    ../main/run-Unimem-nopromote.sh ycsb_a $ycsb_a_512
    ../main/run-Unimem-set.sh ycsb_a $ycsb_a_512
    ../main/run-Unimem-subpage.sh ycsb_a $ycsb_a_128 $ycsb_a_256 $ycsb_a_1k $ycsb_a_2k $ycsb_a_4k
    rm bip-* fifo-* lru-*
    cd ../
    echo "YCSB-A finished"

    echo "run Linear Regression..." 
    cd Metis
    second_line=$(sed -n '2p' metis-count-512)
    metis_512=$(echo "$second_line" | awk -F ':' '{print $2}' | tr -d '[:space:]')
    second_line=$(sed -n '2p' metis-count-4k)
    metis_4k=$(echo "$second_line" | awk -F ':' '{print $2}' | tr -d '[:space:]')
    ../main/run-Page-cache.sh metis $metis_4k
    ../main/run-Kona.sh metis $metis_4k
    ../main/run-Unimem.sh metis $metis_512
    ../main/run-Unimem-nopromote.sh metis $metis_512
    rm bip-* fifo-* lru-*
    cd ../
    echo "Linear Regression finished" 

    echo "run YCSB-B..." 
    cd YCSB-B
    second_line=$(sed -n '2p' ycsb_b-count-512)
    ycsb_b_512=$(echo "$second_line" | awk -F ':' '{print $2}' | tr -d '[:space:]')
    second_line=$(sed -n '2p' ycsb_b-count-4k)
    ycsb_b_4k=$(echo "$second_line" | awk -F ':' '{print $2}' | tr -d '[:space:]')
    ../main/run-Page-cache.sh ycsb_b $ycsb_b_4k
    ../main/run-Kona.sh ycsb_b $ycsb_b_4k
    ../main/run-Unimem.sh ycsb_b $ycsb_b_512
    ../main/run-Unimem-nopromote.sh ycsb_b $ycsb_b_512
    rm bip-* fifo-* lru-*
    cd ../
    echo "YCSB-B finished"

    echo "run mixed workload..." 
    cd mix
    second_line=$(sed -n '2p' mix-count-512)
    mix_512=$(echo "$second_line" | awk -F ':' '{print $2}' | tr -d '[:space:]')
    second_line=$(sed -n '2p' mix-count-4k)
    mix_4k=$(echo "$second_line" | awk -F ':' '{print $2}' | tr -d '[:space:]')
    ../main/run-Page-cache.sh mix $mix_4k
    ../main/run-Kona.sh mix $mix_4k
    ../main/run-Unimem.sh mix $mix_512
    rm bip-* fifo-* lru-*
    cd ../
    echo "mixed workload finished"

# Kona AMAT
Kona_AMAT(){
    local cache_miss_file=$1
    local cache_miss=$(wc -l < $cache_miss_file)
    local out_file=$2
    local last_line=$(tail -n 1 "$out_file")
    local write_back=$(echo "$last_line" | sed -n 's/^#write_back:\(.*\)/\1/p')
    local page_fault=$(($(wc -l < $out_file) - 2))
    local hit=$(($cache_miss - $page_fault))
    local AMAT=$(echo "scale=2; ($hit * $Device_attached_Memory_latency + $page_fault * $Remote_Memory_latency_4KB + $write_back * $Remote_Memory_latency_4KB + $cache_miss * $Address_translation_latency) / $cache_miss" | bc)
    echo "$AMAT"
}
# Kona-PC AMAT
Kona_PC_AMAT(){
    local cache_miss_file=$1
    local cache_miss=$(wc -l < $cache_miss_file)
    local out_file=$2
    local last_line=$(tail -n 1 "$out_file")
    local write_back=$(echo "$last_line" | sed -n 's/^#write_back:\(.*\)/\1/p')
    local page_fault=$(($(wc -l < $out_file) - 6))
    local hit=$(($cache_miss - $page_fault))
    local AMAT=$(echo "scale=2; ($hit * $Device_attached_Memory_latency + $page_fault * $Remote_Memory_latency_4KB + $write_back * $Remote_Memory_latency_4KB + $cache_miss * $Address_translation_latency) / $cache_miss" | bc)
    echo "$AMAT"
}
# SR&RB-4SC AMAT
SR_RB_4SC_AMAT(){
    local cache_miss_file=$1
    local cache_miss=$(wc -l < $cache_miss_file)
    local out_file=$2
    local last_line=$(tail -n 1 "$out_file")
    local write_back=$(echo "$last_line" | sed -n 's/^#write_back:\(.*\)/\1/p')
    local page_fault=$(($(wc -l < $out_file) - 2))
    local hit=$(($cache_miss - $page_fault))
    local AMAT=$(echo "scale=2; ($hit * $Device_attached_Memory_latency + $page_fault * $Remote_Memory_latency_4KB + $write_back * $Remote_Memory_latency_4KB) / $cache_miss" | bc)
    echo "$AMAT"
}
# UniMem-NoPromote AMAT
UniMem_NoPromote_AMAT(){
    local cache_miss_file=$1
    local cache_miss=$(wc -l < $cache_miss_file)
    local out_file=$2
    local wb_line=$(tail -n 1 "$out_file")
    local write_back=$(echo "$wb_line" | sed -n 's/^#write_back:\(.*\)/\1/p')
    local pf_line=$(tail -n 5 "$out_file")
    local page_fault=$(echo "$pf_line" | sed -n 's/^#page_fault:\(.*\)/\1/p')
    local ac_line=$(tail -n 4 "$out_file")
    local active_hit=$(echo "$ac_line" | sed -n 's/^#active_hit:\(.*\)/\1/p')
    local in_line=$(tail -n 3 "$out_file")
    local inactive_hit=$(echo "$in_line" | sed -n 's/^#inactive_hit:\(.*\)/\1/p')
    local hit=$(($active_hit + $inactive_hit))
    local AMAT=$(echo "scale=2; ($hit * $Device_attached_Memory_latency + $page_fault * $Remote_Memory_latency_512B + $write_back * $Remote_Memory_latency_512B) / $cache_miss" | bc)
    echo "$AMAT"
}  
# UniMem AMAT
UniMem_AMAT(){
    local cache_miss_file=$1
    local cache_miss=$(wc -l < $cache_miss_file)
    local out_file=$2
    local wb_4k_line=$(tail -n 1 "$out_file")
    local write_back_4k=$(echo "$wb_4k_line" | sed -n 's/^#write_back_4k:\(.*\)/\1/p')
    local wb_512_line=$(tail -n 2 "$out_file")
    local write_back_512=$(echo "$wb_512_line" | sed -n 's/^#write_back_512:\(.*\)/\1/p')
    local promote_line=$(tail -n 3 "$out_file")
    local promote_num=$(echo "$promote_line" | sed -n 's/^#promote_num:\(.*\)/\1/p')
    local LRU_line=$(tail -n 4 "$out_file")
    local LRU_hit=$(echo "$LRU_line" | sed -n 's/^#LRU_hit:\(.*\)/\1/p')
    local ac_line=$(tail -n 7 "$out_file")
    local active_hit=$(echo "$ac_line" | sed -n 's/^#active_hit:\(.*\)/\1/p')
    local in_line=$(tail -n 6 "$out_file")
    local inactive_hit=$(echo "$in_line" | sed -n 's/^#inactive_hit:\(.*\)/\1/p')
    local hit=$(($active_hit + $inactive_hit))
    local pf_line=$(tail -n 9 "$out_file")
    local page_fault=$(echo "$pf_line" | sed -n 's/^#page_fault:\(.*\)/\1/p')
    local AMAT=$(echo "scale=2; ($LRU_hit * $Host_Memory_latency + $hit * $Device_attached_Memory_latency + $page_fault * $Remote_Memory_latency_512B + $promote_num * $Batch_Promote_latency + $write_back_512 * $Remote_Memory_latency_512B + $write_back_4k * $Remote_Memory_latency_4KB) / $cache_miss" | bc)
    if [[ $out_file == *1k* ]]; then
        AMAT=$(echo "scale=2; ($LRU_hit * $Host_Memory_latency + $hit * $Device_attached_Memory_latency + $page_fault * $Remote_Memory_latency_1KB + $promote_num * $Batch_Promote_latency + $write_back_512 * $Remote_Memory_latency_1KB + $write_back_4k * $Remote_Memory_latency_4KB) / $cache_miss" | bc)
    elif [[ $out_file == *2k* ]]; then
        AMAT=$(echo "scale=2; ($LRU_hit * $Host_Memory_latency + $hit * $Device_attached_Memory_latency + $page_fault * $Remote_Memory_latency_2KB + $promote_num * $Batch_Promote_latency + $write_back_512 * $Remote_Memory_latency_2KB + $write_back_4k * $Remote_Memory_latency_4KB) / $cache_miss" | bc)
    elif [[ $out_file == *4k* ]]; then
        AMAT=$(echo "scale=2; ($LRU_hit * $Host_Memory_latency + $hit * $Device_attached_Memory_latency + $page_fault * $Remote_Memory_latency_4KB + $promote_num * $Batch_Promote_latency + $write_back_512 * $Remote_Memory_latency_4KB + $write_back_4k * $Remote_Memory_latency_4KB) / $cache_miss" | bc)   
    fi
    echo "$AMAT"
}
# Data Amplification
DA(){
    local count_file=$1
    last_line=$(tail -n 1 "$count_file")
    memory_size=$(echo "$last_line" | sed -n 's/#memory_size:\(.*\)KB/\1/p')
    local out_file=$2
    if [[ $out_file == *Kona* ]]; then
        local page_fault=$(($(wc -l < $out_file) - 2))
    elif [[ $out_file == *Pagecache* ]]; then
        local page_fault=$(($(wc -l < $out_file) - 6))
    elif [[ $out_file == *nopromote* ]]; then
        local page_fault=$(($(wc -l < $out_file) - 6))    
    elif [[ $out_file == *Unimem* && $out_file != *nopromote* ]]; then
        local pf_line=$(tail -n 9 "$out_file")
        local page_fault=$(echo "$pf_line" | sed -n 's/^#page_fault:\(.*\)/\1/p')
    fi
    local page_size=$3
    local DA=$(echo "scale=2; $page_size * $page_fault / $memory_size / 1024" | bc)
    echo "$DA"
}
    
    # calculate and generate results
    echo "generating results of Average Memory Access Time..."
    systems=(Kona Kona-PC SR\&RB-4SC UniMem-NoPromote UniMem)
    mkdir 4.2_Average_Memory_Access_Time
    cd 4.2_Average_Memory_Access_Time
    echo "generating Average Memory Access Time results of Facebook-ETC"
    echo -e "local_cache_size\t100%\t75%\t50%\t25%\t10%" > Facebook-ETC
    for i in ${systems[@]}
    do
	if [[ $i == Kona ]]; then
    	  echo -e "$i\t$(Kona_AMAT ../Memcache/memcache-cache_miss ../Memcache/memcache-Kona-100out)\t$(Kona_AMAT ../Memcache/memcache-cache_miss ../Memcache/memcache-Kona-75out)\t$(Kona_AMAT ../Memcache/memcache-cache_miss ../Memcache/memcache-Kona-50out)\t$(Kona_AMAT ../Memcache/memcache-cache_miss ../Memcache/memcache-Kona-25out)\t$(Kona_AMAT ../Memcache/memcache-cache_miss ../Memcache/memcache-Kona-10out)" >>  Facebook-ETC
	elif [[ $i == Kona-PC ]]; then
    	  echo -e "$i\t$(Kona_PC_AMAT ../Memcache/memcache-cache_miss ../Memcache/memcache-Pagecache-100out)\t$(Kona_PC_AMAT ../Memcache/memcache-cache_miss ../Memcache/memcache-Pagecache-75out)\t$(Kona_PC_AMAT ../Memcache/memcache-cache_miss ../Memcache/memcache-Pagecache-50out)\t$(Kona_PC_AMAT ../Memcache/memcache-cache_miss ../Memcache/memcache-Pagecache-25out)\t$(Kona_PC_AMAT ../Memcache/memcache-cache_miss ../Memcache/memcache-Pagecache-10out)" >>  Facebook-ETC
	elif [[ $i == SR\&RB-4SC ]]; then
	    echo -e "$i\t$(SR_RB_4SC_AMAT ../Memcache/memcache-cache_miss ../Memcache/memcache-Kona-100out)\t$(SR_RB_4SC_AMAT ../Memcache/memcache-cache_miss ../Memcache/memcache-Kona-75out)\t$(SR_RB_4SC_AMAT ../Memcache/memcache-cache_miss ../Memcache/memcache-Kona-50out)\t$(SR_RB_4SC_AMAT ../Memcache/memcache-cache_miss ../Memcache/memcache-Kona-25out)\t$(SR_RB_4SC_AMAT ../Memcache/memcache-cache_miss ../Memcache/memcache-Kona-10out)" >>  Facebook-ETC
    elif [[ $i == UniMem-NoPromote ]]; then
        echo -e "$i\t$(UniMem_NoPromote_AMAT ../Memcache/memcache-cache_miss ../Memcache/memcache-Unimem-nopromote-100out)\t$(UniMem_NoPromote_AMAT ../Memcache/memcache-cache_miss ../Memcache/memcache-Unimem-nopromote-75out)\t$(UniMem_NoPromote_AMAT ../Memcache/memcache-cache_miss ../Memcache/memcache-Unimem-nopromote-50out)\t$(UniMem_NoPromote_AMAT ../Memcache/memcache-cache_miss ../Memcache/memcache-Unimem-nopromote-25out)\t$(UniMem_NoPromote_AMAT ../Memcache/memcache-cache_miss ../Memcache/memcache-Unimem-nopromote-10out)" >>  Facebook-ETC
	elif [[ $i == UniMem ]]; then
	    echo -e "$i\t$(UniMem_AMAT ../Memcache/memcache-cache_miss ../Memcache/memcache-Unimem-100out)\t$(UniMem_AMAT ../Memcache/memcache-cache_miss ../Memcache/memcache-Unimem-75out)\t$(UniMem_AMAT ../Memcache/memcache-cache_miss ../Memcache/memcache-Unimem-50out)\t$(UniMem_AMAT ../Memcache/memcache-cache_miss ../Memcache/memcache-Unimem-25out)\t$(UniMem_AMAT ../Memcache/memcache-cache_miss ../Memcache/memcache-Unimem-10out)" >>  Facebook-ETC
    fi
    done
    echo "generating Average Memory Access Time results of Redis-Rand"
    echo -e "local_cache_size\t100%\t75%\t50%\t25%\t10%" > Redis-Rand
    for i in ${systems[@]}
    do
	if [[ $i == Kona ]]; then
    	  echo -e "$i\t$(Kona_AMAT ../Redis/redis-cache_miss ../Redis/redis-Kona-100out)\t$(Kona_AMAT ../Redis/redis-cache_miss ../Redis/redis-Kona-75out)\t$(Kona_AMAT ../Redis/redis-cache_miss ../Redis/redis-Kona-50out)\t$(Kona_AMAT ../Redis/redis-cache_miss ../Redis/redis-Kona-25out)\t$(Kona_AMAT ../Redis/redis-cache_miss ../Redis/redis-Kona-10out)" >>  Redis-Rand
	elif [[ $i == Kona-PC ]]; then
    	  echo -e "$i\t$(Kona_PC_AMAT ../Redis/redis-cache_miss ../Redis/redis-Pagecache-100out)\t$(Kona_PC_AMAT ../Redis/redis-cache_miss ../Redis/redis-Pagecache-75out)\t$(Kona_PC_AMAT ../Redis/redis-cache_miss ../Redis/redis-Pagecache-50out)\t$(Kona_PC_AMAT ../Redis/redis-cache_miss ../Redis/redis-Pagecache-25out)\t$(Kona_PC_AMAT ../Redis/redis-cache_miss ../Redis/redis-Pagecache-10out)" >>  Redis-Rand
	elif [[ $i == SR\&RB-4SC ]]; then
	    echo -e "$i\t$(SR_RB_4SC_AMAT ../Redis/redis-cache_miss ../Redis/redis-Kona-100out)\t$(SR_RB_4SC_AMAT ../Redis/redis-cache_miss ../Redis/redis-Kona-75out)\t$(SR_RB_4SC_AMAT ../Redis/redis-cache_miss ../Redis/redis-Kona-50out)\t$(SR_RB_4SC_AMAT ../Redis/redis-cache_miss ../Redis/redis-Kona-25out)\t$(SR_RB_4SC_AMAT ../Redis/redis-cache_miss ../Redis/redis-Kona-10out)" >>  Redis-Rand
    elif [[ $i == UniMem-NoPromote ]]; then
        echo -e "$i\t$(UniMem_NoPromote_AMAT ../Redis/redis-cache_miss ../Redis/redis-Unimem-nopromote-100out)\t$(UniMem_NoPromote_AMAT ../Redis/redis-cache_miss ../Redis/redis-Unimem-nopromote-75out)\t$(UniMem_NoPromote_AMAT ../Redis/redis-cache_miss ../Redis/redis-Unimem-nopromote-50out)\t$(UniMem_NoPromote_AMAT ../Redis/redis-cache_miss ../Redis/redis-Unimem-nopromote-25out)\t$(UniMem_NoPromote_AMAT ../Redis/redis-cache_miss ../Redis/redis-Unimem-nopromote-10out)" >>  Redis-Rand
	elif [[ $i == UniMem ]]; then
	    echo -e "$i\t$(UniMem_AMAT ../Redis/redis-cache_miss ../Redis/redis-Unimem-100out)\t$(UniMem_AMAT ../Redis/redis-cache_miss ../Redis/redis-Unimem-75out)\t$(UniMem_AMAT ../Redis/redis-cache_miss ../Redis/redis-Unimem-50out)\t$(UniMem_AMAT ../Redis/redis-cache_miss ../Redis/redis-Unimem-25out)\t$(UniMem_AMAT ../Redis/redis-cache_miss ../Redis/redis-Unimem-10out)" >>  Redis-Rand
    fi
    done
    echo "generating Average Memory Access Time results of YCSB-A"
    echo -e "local_cache_size\t100%\t75%\t50%\t25%\t10%" > YCSB-A
    for i in ${systems[@]}
    do
	if [[ $i == Kona ]]; then
    	  echo -e "$i\t$(Kona_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Kona-100out)\t$(Kona_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Kona-75out)\t$(Kona_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Kona-50out)\t$(Kona_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Kona-25out)\t$(Kona_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Kona-10out)" >>  YCSB-A
	elif [[ $i == Kona-PC ]]; then
    	  echo -e "$i\t$(Kona_PC_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Pagecache-100out)\t$(Kona_PC_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Pagecache-75out)\t$(Kona_PC_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Pagecache-50out)\t$(Kona_PC_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Pagecache-25out)\t$(Kona_PC_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Pagecache-10out)" >>  YCSB-A
	elif [[ $i == SR\&RB-4SC ]]; then
	    echo -e "$i\t$(SR_RB_4SC_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Kona-100out)\t$(SR_RB_4SC_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Kona-75out)\t$(SR_RB_4SC_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Kona-50out)\t$(SR_RB_4SC_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Kona-25out)\t$(SR_RB_4SC_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Kona-10out)" >>  YCSB-A
    elif [[ $i == UniMem-NoPromote ]]; then
        echo -e "$i\t$(UniMem_NoPromote_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Unimem-nopromote-100out)\t$(UniMem_NoPromote_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Unimem-nopromote-75out)\t$(UniMem_NoPromote_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Unimem-nopromote-50out)\t$(UniMem_NoPromote_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Unimem-nopromote-25out)\t$(UniMem_NoPromote_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Unimem-nopromote-10out)" >>  YCSB-A
	elif [[ $i == UniMem ]]; then
	    echo -e "$i\t$(UniMem_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Unimem-100out)\t$(UniMem_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Unimem-75out)\t$(UniMem_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Unimem-50out)\t$(UniMem_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Unimem-25out)\t$(UniMem_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Unimem-10out)" >>  YCSB-A
    fi
    done
    echo "generating Average Memory Access Time results of YCSB-B"
    echo -e "local_cache_size\t100%\t75%\t50%\t25%\t10%" > YCSB-B
    for i in ${systems[@]}
    do
	if [[ $i == Kona ]]; then
    	  echo -e "$i\t$(Kona_AMAT ../YCSB-B/ycsb_b-cache_miss ../YCSB-B/ycsb_b-Kona-100out)\t$(Kona_AMAT ../YCSB-B/ycsb_b-cache_miss ../YCSB-B/ycsb_b-Kona-75out)\t$(Kona_AMAT ../YCSB-B/ycsb_b-cache_miss ../YCSB-B/ycsb_b-Kona-50out)\t$(Kona_AMAT ../YCSB-B/ycsb_b-cache_miss ../YCSB-B/ycsb_b-Kona-25out)\t$(Kona_AMAT ../YCSB-B/ycsb_b-cache_miss ../YCSB-B/ycsb_b-Kona-10out)" >>  YCSB-B
	elif [[ $i == Kona-PC ]]; then
    	  echo -e "$i\t$(Kona_PC_AMAT ../YCSB-B/ycsb_b-cache_miss ../YCSB-B/ycsb_b-Pagecache-100out)\t$(Kona_PC_AMAT ../YCSB-B/ycsb_b-cache_miss ../YCSB-B/ycsb_b-Pagecache-75out)\t$(Kona_PC_AMAT ../YCSB-B/ycsb_b-cache_miss ../YCSB-B/ycsb_b-Pagecache-50out)\t$(Kona_PC_AMAT ../YCSB-B/ycsb_b-cache_miss ../YCSB-B/ycsb_b-Pagecache-25out)\t$(Kona_PC_AMAT ../YCSB-B/ycsb_b-cache_miss ../YCSB-B/ycsb_b-Pagecache-10out)" >>  YCSB-B
	elif [[ $i == SR\&RB-4SC ]]; then
	    echo -e "$i\t$(SR_RB_4SC_AMAT ../YCSB-B/ycsb_b-cache_miss ../YCSB-B/ycsb_b-Kona-100out)\t$(SR_RB_4SC_AMAT ../YCSB-B/ycsb_b-cache_miss ../YCSB-B/ycsb_b-Kona-75out)\t$(SR_RB_4SC_AMAT ../YCSB-B/ycsb_b-cache_miss ../YCSB-B/ycsb_b-Kona-50out)\t$(SR_RB_4SC_AMAT ../YCSB-B/ycsb_b-cache_miss ../YCSB-B/ycsb_b-Kona-25out)\t$(SR_RB_4SC_AMAT ../YCSB-B/ycsb_b-cache_miss ../YCSB-B/ycsb_b-Kona-10out)" >>  YCSB-B
    elif [[ $i == UniMem-NoPromote ]]; then
        echo -e "$i\t$(UniMem_NoPromote_AMAT ../YCSB-B/ycsb_b-cache_miss ../YCSB-B/ycsb_b-Unimem-nopromote-100out)\t$(UniMem_NoPromote_AMAT ../YCSB-B/ycsb_b-cache_miss ../YCSB-B/ycsb_b-Unimem-nopromote-75out)\t$(UniMem_NoPromote_AMAT ../YCSB-B/ycsb_b-cache_miss ../YCSB-B/ycsb_b-Unimem-nopromote-50out)\t$(UniMem_NoPromote_AMAT ../YCSB-B/ycsb_b-cache_miss ../YCSB-B/ycsb_b-Unimem-nopromote-25out)\t$(UniMem_NoPromote_AMAT ../YCSB-B/ycsb_b-cache_miss ../YCSB-B/ycsb_b-Unimem-nopromote-10out)" >>  YCSB-B
	elif [[ $i == UniMem ]]; then
	    echo -e "$i\t$(UniMem_AMAT ../YCSB-B/ycsb_b-cache_miss ../YCSB-B/ycsb_b-Unimem-100out)\t$(UniMem_AMAT ../YCSB-B/ycsb_b-cache_miss ../YCSB-B/ycsb_b-Unimem-75out)\t$(UniMem_AMAT ../YCSB-B/ycsb_b-cache_miss ../YCSB-B/ycsb_b-Unimem-50out)\t$(UniMem_AMAT ../YCSB-B/ycsb_b-cache_miss ../YCSB-B/ycsb_b-Unimem-25out)\t$(UniMem_AMAT ../YCSB-B/ycsb_b-cache_miss ../YCSB-B/ycsb_b-Unimem-10out)" >>  YCSB-B
    fi
    done
    echo "generating Average Memory Access Time results of Page-Rank"
    echo -e "local_cache_size\t100%\t75%\t50%\t25%\t10%" > Page-Rank
    for i in ${systems[@]}
    do
	if [[ $i == Kona ]]; then
    	  echo -e "$i\t$(Kona_AMAT ../Pagerank/pagerank-cache_miss ../Pagerank/pagerank-Kona-100out)\t$(Kona_AMAT ../Pagerank/pagerank-cache_miss ../Pagerank/pagerank-Kona-75out)\t$(Kona_AMAT ../Pagerank/pagerank-cache_miss ../Pagerank/pagerank-Kona-50out)\t$(Kona_AMAT ../Pagerank/pagerank-cache_miss ../Pagerank/pagerank-Kona-25out)\t$(Kona_AMAT ../Pagerank/pagerank-cache_miss ../Pagerank/pagerank-Kona-10out)" >>  Page-Rank
	elif [[ $i == Kona-PC ]]; then
    	  echo -e "$i\t$(Kona_PC_AMAT ../Pagerank/pagerank-cache_miss ../Pagerank/pagerank-Pagecache-100out)\t$(Kona_PC_AMAT ../Pagerank/pagerank-cache_miss ../Pagerank/pagerank-Pagecache-75out)\t$(Kona_PC_AMAT ../Pagerank/pagerank-cache_miss ../Pagerank/pagerank-Pagecache-50out)\t$(Kona_PC_AMAT ../Pagerank/pagerank-cache_miss ../Pagerank/pagerank-Pagecache-25out)\t$(Kona_PC_AMAT ../Pagerank/pagerank-cache_miss ../Pagerank/pagerank-Pagecache-10out)" >>  Page-Rank
	elif [[ $i == SR\&RB-4SC ]]; then
	    echo -e "$i\t$(SR_RB_4SC_AMAT ../Pagerank/pagerank-cache_miss ../Pagerank/pagerank-Kona-100out)\t$(SR_RB_4SC_AMAT ../Pagerank/pagerank-cache_miss ../Pagerank/pagerank-Kona-75out)\t$(SR_RB_4SC_AMAT ../Pagerank/pagerank-cache_miss ../Pagerank/pagerank-Kona-50out)\t$(SR_RB_4SC_AMAT ../Pagerank/pagerank-cache_miss ../Pagerank/pagerank-Kona-25out)\t$(SR_RB_4SC_AMAT ../Pagerank/pagerank-cache_miss ../Pagerank/pagerank-Kona-10out)" >>  Page-Rank
    elif [[ $i == UniMem-NoPromote ]]; then
        echo -e "$i\t$(UniMem_NoPromote_AMAT ../Pagerank/pagerank-cache_miss ../Pagerank/pagerank-Unimem-nopromote-100out)\t$(UniMem_NoPromote_AMAT ../Pagerank/pagerank-cache_miss ../Pagerank/pagerank-Unimem-nopromote-75out)\t$(UniMem_NoPromote_AMAT ../Pagerank/pagerank-cache_miss ../Pagerank/pagerank-Unimem-nopromote-50out)\t$(UniMem_NoPromote_AMAT ../Pagerank/pagerank-cache_miss ../Pagerank/pagerank-Unimem-nopromote-25out)\t$(UniMem_NoPromote_AMAT ../Pagerank/pagerank-cache_miss ../Pagerank/pagerank-Unimem-nopromote-10out)" >>  Page-Rank
	elif [[ $i == UniMem ]]; then
	    echo -e "$i\t$(UniMem_AMAT ../Pagerank/pagerank-cache_miss ../Pagerank/pagerank-Unimem-100out)\t$(UniMem_AMAT ../Pagerank/pagerank-cache_miss ../Pagerank/pagerank-Unimem-75out)\t$(UniMem_AMAT ../Pagerank/pagerank-cache_miss ../Pagerank/pagerank-Unimem-50out)\t$(UniMem_AMAT ../Pagerank/pagerank-cache_miss ../Pagerank/pagerank-Unimem-25out)\t$(UniMem_AMAT ../Pagerank/pagerank-cache_miss ../Pagerank/pagerank-Unimem-10out)" >>  Page-Rank
    fi
    done
    echo "generating Average Memory Access Time results of Linear-Regression"
    echo -e "local_cache_size\t100%\t75%\t50%\t25%\t10%" > Linear-Regression
    for i in ${systems[@]}
    do
	if [[ $i == Kona ]]; then
    	  echo -e "$i\t$(Kona_AMAT ../Metis/metis-cache_miss ../Metis/metis-Kona-100out)\t$(Kona_AMAT ../Metis/metis-cache_miss ../Metis/metis-Kona-75out)\t$(Kona_AMAT ../Metis/metis-cache_miss ../Metis/metis-Kona-50out)\t$(Kona_AMAT ../Metis/metis-cache_miss ../Metis/metis-Kona-25out)\t$(Kona_AMAT ../Metis/metis-cache_miss ../Metis/metis-Kona-10out)" >>  Linear-Regression
	elif [[ $i == Kona-PC ]]; then
    	  echo -e "$i\t$(Kona_PC_AMAT ../Metis/metis-cache_miss ../Metis/metis-Pagecache-100out)\t$(Kona_PC_AMAT ../Metis/metis-cache_miss ../Metis/metis-Pagecache-75out)\t$(Kona_PC_AMAT ../Metis/metis-cache_miss ../Metis/metis-Pagecache-50out)\t$(Kona_PC_AMAT ../Metis/metis-cache_miss ../Metis/metis-Pagecache-25out)\t$(Kona_PC_AMAT ../Metis/metis-cache_miss ../Metis/metis-Pagecache-10out)" >>  Linear-Regression
	elif [[ $i == SR\&RB-4SC ]]; then
	    echo -e "$i\t$(SR_RB_4SC_AMAT ../Metis/metis-cache_miss ../Metis/metis-Kona-100out)\t$(SR_RB_4SC_AMAT ../Metis/metis-cache_miss ../Metis/metis-Kona-75out)\t$(SR_RB_4SC_AMAT ../Metis/metis-cache_miss ../Metis/metis-Kona-50out)\t$(SR_RB_4SC_AMAT ../Metis/metis-cache_miss ../Metis/metis-Kona-25out)\t$(SR_RB_4SC_AMAT ../Metis/metis-cache_miss ../Metis/metis-Kona-10out)" >>  Linear-Regression
    elif [[ $i == UniMem-NoPromote ]]; then
        echo -e "$i\t$(UniMem_NoPromote_AMAT ../Metis/metis-cache_miss ../Metis/metis-Unimem-nopromote-100out)\t$(UniMem_NoPromote_AMAT ../Metis/metis-cache_miss ../Metis/metis-Unimem-nopromote-75out)\t$(UniMem_NoPromote_AMAT ../Metis/metis-cache_miss ../Metis/metis-Unimem-nopromote-50out)\t$(UniMem_NoPromote_AMAT ../Metis/metis-cache_miss ../Metis/metis-Unimem-nopromote-25out)\t$(UniMem_NoPromote_AMAT ../Metis/metis-cache_miss ../Metis/metis-Unimem-nopromote-10out)" >>  Linear-Regression
	elif [[ $i == UniMem ]]; then
	    echo -e "$i\t$(UniMem_AMAT ../Metis/metis-cache_miss ../Metis/metis-Unimem-100out)\t$(UniMem_AMAT ../Metis/metis-cache_miss ../Metis/metis-Unimem-75out)\t$(UniMem_AMAT ../Metis/metis-cache_miss ../Metis/metis-Unimem-50out)\t$(UniMem_AMAT ../Metis/metis-cache_miss ../Metis/metis-Unimem-25out)\t$(UniMem_AMAT ../Metis/metis-cache_miss ../Metis/metis-Unimem-10out)" >>  Linear-Regression
    fi
    done
    cd ../

    echo "generating results of Data Amplification..."
    systems=(Kona Kona-PC UniMem)
    mkdir 4.3_Data_Amplification
    cd 4.3_Data_Amplification
    echo "generating Data Amplification results of Facebook-ETC"
    echo -e "local_cache_size\t100%\t75%\t50%\t25%\t10%" > Facebook-ETC
    for i in ${systems[@]}
    do
	if [[ $i == Kona ]]; then
    	echo -e "$i\t$(DA ../Memcache/memcache-count-4k ../Memcache/memcache-Kona-100out 4096)\t$(DA ../Memcache/memcache-count-4k ../Memcache/memcache-Kona-75out 4096)\t$(DA ../Memcache/memcache-count-4k ../Memcache/memcache-Kona-50out 4096)\t$(DA ../Memcache/memcache-count-4k ../Memcache/memcache-Kona-25out 4096)\t$(DA ../Memcache/memcache-count-4k ../Memcache/memcache-Kona-10out 4096)" >>  Facebook-ETC
	elif [[ $i == Kona-PC ]]; then
        echo -e "$i\t$(DA ../Memcache/memcache-count-4k ../Memcache/memcache-Pagecache-100out 4096)\t$(DA ../Memcache/memcache-count-4k ../Memcache/memcache-Pagecache-75out 4096)\t$(DA ../Memcache/memcache-count-4k ../Memcache/memcache-Pagecache-50out 4096)\t$(DA ../Memcache/memcache-count-4k ../Memcache/memcache-Pagecache-25out 4096)\t$(DA ../Memcache/memcache-count-4k ../Memcache/memcache-Pagecache-10out 4096)" >>  Facebook-ETC
	elif [[ $i == UniMem ]]; then
	    echo -e "$i\t$(DA ../Memcache/memcache-count-512 ../Memcache/memcache-Unimem-100out 512)\t$(DA ../Memcache/memcache-count-512 ../Memcache/memcache-Unimem-75out 512)\t$(DA ../Memcache/memcache-count-512 ../Memcache/memcache-Unimem-50out 512)\t$(DA ../Memcache/memcache-count-512 ../Memcache/memcache-Unimem-25out 512)\t$(DA ../Memcache/memcache-count-512 ../Memcache/memcache-Unimem-10out 512)" >>  Facebook-ETC
    fi
    done
    echo "generating Data Amplification results of Redis-Rand"
    echo -e "local_cache_size\t100%\t75%\t50%\t25%\t10%" > Redis-Rand
    for i in ${systems[@]}
    do
	if [[ $i == Kona ]]; then
    	echo -e "$i\t$(DA ../Redis/redis-count-4k ../Redis/redis-Kona-100out 4096)\t$(DA ../Redis/redis-count-4k ../Redis/redis-Kona-75out 4096)\t$(DA ../Redis/redis-count-4k ../Redis/redis-Kona-50out 4096)\t$(DA ../Redis/redis-count-4k ../Redis/redis-Kona-25out 4096)\t$(DA ../Redis/redis-count-4k ../Redis/redis-Kona-10out 4096)" >>  Redis-Rand
	elif [[ $i == Kona-PC ]]; then
        echo -e "$i\t$(DA ../Redis/redis-count-4k ../Redis/redis-Pagecache-100out 4096)\t$(DA ../Redis/redis-count-4k ../Redis/redis-Pagecache-75out 4096)\t$(DA ../Redis/redis-count-4k ../Redis/redis-Pagecache-50out 4096)\t$(DA ../Redis/redis-count-4k ../Redis/redis-Pagecache-25out 4096)\t$(DA ../Redis/redis-count-4k ../Redis/redis-Pagecache-10out 4096)" >>  Redis-Rand
	elif [[ $i == UniMem ]]; then
	    echo -e "$i\t$(DA ../Redis/redis-count-512 ../Redis/redis-Unimem-100out 512)\t$(DA ../Redis/redis-count-512 ../Redis/redis-Unimem-75out 512)\t$(DA ../Redis/redis-count-512 ../Redis/redis-Unimem-50out 512)\t$(DA ../Redis/redis-count-512 ../Redis/redis-Unimem-25out 512)\t$(DA ../Redis/redis-count-512 ../Redis/redis-Unimem-10out 512)" >>  Redis-Rand
    fi
    done
    echo "generating Data Amplification results of YCSB-A"
    echo -e "local_cache_size\t100%\t75%\t50%\t25%\t10%" > YCSB-A
    for i in ${systems[@]}
    do
	if [[ $i == Kona ]]; then
    	echo -e "$i\t$(DA ../YCSB-A/ycsb_a-count-4k ../YCSB-A/ycsb_a-Kona-100out 4096)\t$(DA ../YCSB-A/ycsb_a-count-4k ../YCSB-A/ycsb_a-Kona-75out 4096)\t$(DA ../YCSB-A/ycsb_a-count-4k ../YCSB-A/ycsb_a-Kona-50out 4096)\t$(DA ../YCSB-A/ycsb_a-count-4k ../YCSB-A/ycsb_a-Kona-25out 4096)\t$(DA ../YCSB-A/ycsb_a-count-4k ../YCSB-A/ycsb_a-Kona-10out 4096)" >>  YCSB-A
	elif [[ $i == Kona-PC ]]; then
        echo -e "$i\t$(DA ../YCSB-A/ycsb_a-count-4k ../YCSB-A/ycsb_a-Pagecache-100out 4096)\t$(DA ../YCSB-A/ycsb_a-count-4k ../YCSB-A/ycsb_a-Pagecache-75out 4096)\t$(DA ../YCSB-A/ycsb_a-count-4k ../YCSB-A/ycsb_a-Pagecache-50out 4096)\t$(DA ../YCSB-A/ycsb_a-count-4k ../YCSB-A/ycsb_a-Pagecache-25out 4096)\t$(DA ../YCSB-A/ycsb_a-count-4k ../YCSB-A/ycsb_a-Pagecache-10out 4096)" >>  YCSB-A
	elif [[ $i == UniMem ]]; then
	    echo -e "$i\t$(DA ../YCSB-A/ycsb_a-count-512 ../YCSB-A/ycsb_a-Unimem-100out 512)\t$(DA ../YCSB-A/ycsb_a-count-512 ../YCSB-A/ycsb_a-Unimem-75out 512)\t$(DA ../YCSB-A/ycsb_a-count-512 ../YCSB-A/ycsb_a-Unimem-50out 512)\t$(DA ../YCSB-A/ycsb_a-count-512 ../YCSB-A/ycsb_a-Unimem-25out 512)\t$(DA ../YCSB-A/ycsb_a-count-512 ../YCSB-A/ycsb_a-Unimem-10out 512)" >>  YCSB-A
    fi
    done
    echo "generating Data Amplification results of YCSB-B"
    echo -e "local_cache_size\t100%\t75%\t50%\t25%\t10%" > YCSB-B
    for i in ${systems[@]}
    do
	if [[ $i == Kona ]]; then
    	echo -e "$i\t$(DA ../YCSB-B/ycsb_b-count-4k ../YCSB-B/ycsb_b-Kona-100out 4096)\t$(DA ../YCSB-B/ycsb_b-count-4k ../YCSB-B/ycsb_b-Kona-75out 4096)\t$(DA ../YCSB-B/ycsb_b-count-4k ../YCSB-B/ycsb_b-Kona-50out 4096)\t$(DA ../YCSB-B/ycsb_b-count-4k ../YCSB-B/ycsb_b-Kona-25out 4096)\t$(DA ../YCSB-B/ycsb_b-count-4k ../YCSB-B/ycsb_b-Kona-10out 4096)" >>  YCSB-B
	elif [[ $i == Kona-PC ]]; then
        echo -e "$i\t$(DA ../YCSB-B/ycsb_b-count-4k ../YCSB-B/ycsb_b-Pagecache-100out 4096)\t$(DA ../YCSB-B/ycsb_b-count-4k ../YCSB-B/ycsb_b-Pagecache-75out 4096)\t$(DA ../YCSB-B/ycsb_b-count-4k ../YCSB-B/ycsb_b-Pagecache-50out 4096)\t$(DA ../YCSB-B/ycsb_b-count-4k ../YCSB-B/ycsb_b-Pagecache-25out 4096)\t$(DA ../YCSB-B/ycsb_b-count-4k ../YCSB-B/ycsb_b-Pagecache-10out 4096)" >>  YCSB-B
	elif [[ $i == UniMem ]]; then
	    echo -e "$i\t$(DA ../YCSB-B/ycsb_b-count-512 ../YCSB-B/ycsb_b-Unimem-100out 512)\t$(DA ../YCSB-B/ycsb_b-count-512 ../YCSB-B/ycsb_b-Unimem-75out 512)\t$(DA ../YCSB-B/ycsb_b-count-512 ../YCSB-B/ycsb_b-Unimem-50out 512)\t$(DA ../YCSB-B/ycsb_b-count-512 ../YCSB-B/ycsb_b-Unimem-25out 512)\t$(DA ../YCSB-B/ycsb_b-count-512 ../YCSB-B/ycsb_b-Unimem-10out 512)" >>  YCSB-B
    fi
    done
    echo "generating Data Amplification results of Page-Rank"
    echo -e "local_cache_size\t100%\t75%\t50%\t25%\t10%" > Page-Rank
    for i in ${systems[@]}
    do
	if [[ $i == Kona ]]; then
    	echo -e "$i\t$(DA ../Pagerank/pagerank-count-4k ../Pagerank/pagerank-Kona-100out 4096)\t$(DA ../Pagerank/pagerank-count-4k ../Pagerank/pagerank-Kona-75out 4096)\t$(DA ../Pagerank/pagerank-count-4k ../Pagerank/pagerank-Kona-50out 4096)\t$(DA ../Pagerank/pagerank-count-4k ../Pagerank/pagerank-Kona-25out 4096)\t$(DA ../Pagerank/pagerank-count-4k ../Pagerank/pagerank-Kona-10out 4096)" >>  Page-Rank
	elif [[ $i == Kona-PC ]]; then
        echo -e "$i\t$(DA ../Pagerank/pagerank-count-4k ../Pagerank/pagerank-Pagecache-100out 4096)\t$(DA ../Pagerank/pagerank-count-4k ../Pagerank/pagerank-Pagecache-75out 4096)\t$(DA ../Pagerank/pagerank-count-4k ../Pagerank/pagerank-Pagecache-50out 4096)\t$(DA ../Pagerank/pagerank-count-4k ../Pagerank/pagerank-Pagecache-25out 4096)\t$(DA ../Pagerank/pagerank-count-4k ../Pagerank/pagerank-Pagecache-10out 4096)" >>  Page-Rank
	elif [[ $i == UniMem ]]; then
	    echo -e "$i\t$(DA ../Pagerank/pagerank-count-512 ../Pagerank/pagerank-Unimem-100out 512)\t$(DA ../Pagerank/pagerank-count-512 ../Pagerank/pagerank-Unimem-75out 512)\t$(DA ../Pagerank/pagerank-count-512 ../Pagerank/pagerank-Unimem-50out 512)\t$(DA ../Pagerank/pagerank-count-512 ../Pagerank/pagerank-Unimem-25out 512)\t$(DA ../Pagerank/pagerank-count-512 ../Pagerank/pagerank-Unimem-10out 512)" >>  Page-Rank
    fi
    done
    echo "generating Data Amplification results of Linear-Regression"
    echo -e "local_cache_size\t100%\t75%\t50%\t25%\t10%" > Linear-Regression
    for i in ${systems[@]}
    do
	if [[ $i == Kona ]]; then
    	echo -e "$i\t$(DA ../Metis/metis-count-4k ../Metis/metis-Kona-100out 4096)\t$(DA ../Metis/metis-count-4k ../Metis/metis-Kona-75out 4096)\t$(DA ../Metis/metis-count-4k ../Metis/metis-Kona-50out 4096)\t$(DA ../Metis/metis-count-4k ../Metis/metis-Kona-25out 4096)\t$(DA ../Metis/metis-count-4k ../Metis/metis-Kona-10out 4096)" >>   Linear-Regression
	elif [[ $i == Kona-PC ]]; then
        echo -e "$i\t$(DA ../Metis/metis-count-4k ../Metis/metis-Pagecache-100out 4096)\t$(DA ../Metis/metis-count-4k ../Metis/metis-Pagecache-75out 4096)\t$(DA ../Metis/metis-count-4k ../Metis/metis-Pagecache-50out 4096)\t$(DA ../Metis/metis-count-4k ../Metis/metis-Pagecache-25out 4096)\t$(DA ../Metis/metis-count-4k ../Metis/metis-Pagecache-10out 4096)" >>   Linear-Regression
	elif [[ $i == UniMem ]]; then
	    echo -e "$i\t$(DA ../Metis/metis-count-512 ../Metis/metis-Unimem-100out 512)\t$(DA ../Metis/metis-count-512 ../Metis/metis-Unimem-75out 512)\t$(DA ../Metis/metis-count-512 ../Metis/metis-Unimem-50out 512)\t$(DA ../Metis/metis-count-512 ../Metis/metis-Unimem-25out 512)\t$(DA ../Metis/metis-count-512 ../Metis/metis-Unimem-10out 512)" >>   Linear-Regression
    fi
    done
    cd ../

    echo "generating results of Mixed Workload..."
    systems=(Kona Kona-PC UniMem)
    mkdir 4.4_Mixed_Workload
    cd 4.4_Mixed_Workload
    echo "generating Average Memory Access Time results of Mixed Workload"
    echo -e "local_cache_size\t100%\t75%\t50%\t25%\t10%" > AMAT
    for i in ${systems[@]}
    do
	if [[ $i == Kona ]]; then
    	  echo -e "$i\t$(Kona_AMAT ../mix/mix-cache_miss ../mix/mix-Kona-100out)\t$(Kona_AMAT ../mix/mix-cache_miss ../mix/mix-Kona-75out)\t$(Kona_AMAT ../mix/mix-cache_miss ../mix/mix-Kona-50out)\t$(Kona_AMAT ../mix/mix-cache_miss ../mix/mix-Kona-25out)\t$(Kona_AMAT ../mix/mix-cache_miss ../mix/mix-Kona-10out)" >>  AMAT
	elif [[ $i == Kona-PC ]]; then
    	  echo -e "$i\t$(Kona_PC_AMAT ../mix/mix-cache_miss ../mix/mix-Pagecache-100out)\t$(Kona_PC_AMAT ../mix/mix-cache_miss ../mix/mix-Pagecache-75out)\t$(Kona_PC_AMAT ../mix/mix-cache_miss ../mix/mix-Pagecache-50out)\t$(Kona_PC_AMAT ../mix/mix-cache_miss ../mix/mix-Pagecache-25out)\t$(Kona_PC_AMAT ../mix/mix-cache_miss ../mix/mix-Pagecache-10out)" >>  AMAT
	elif [[ $i == UniMem ]]; then
	    echo -e "$i\t$(UniMem_AMAT ../mix/mix-cache_miss ../mix/mix-Unimem-100out)\t$(UniMem_AMAT ../mix/mix-cache_miss ../mix/mix-Unimem-75out)\t$(UniMem_AMAT ../mix/mix-cache_miss ../mix/mix-Unimem-50out)\t$(UniMem_AMAT ../mix/mix-cache_miss ../mix/mix-Unimem-25out)\t$(UniMem_AMAT ../mix/mix-cache_miss ../mix/mix-Unimem-10out)" >>  AMAT
    fi
    done
    echo "generating Data Amplification results of Mixed Workload"
    echo -e "local_cache_size\t100%\t75%\t50%\t25%\t10%" > DA
    for i in ${systems[@]}
    do
	if [[ $i == Kona ]]; then
    	echo -e "$i\t$(DA ../mix/mix-count-4k ../mix/mix-Kona-100out 4096)\t$(DA ../mix/mix-count-4k ../mix/mix-Kona-75out 4096)\t$(DA ../mix/mix-count-4k ../mix/mix-Kona-50out 4096)\t$(DA ../mix/mix-count-4k ../mix/mix-Kona-25out 4096)\t$(DA ../mix/mix-count-4k ../mix/mix-Kona-10out 4096)" >>  DA
	elif [[ $i == Kona-PC ]]; then
        echo -e "$i\t$(DA ../mix/mix-count-4k ../mix/mix-Pagecache-100out 4096)\t$(DA ../mix/mix-count-4k ../mix/mix-Pagecache-75out 4096)\t$(DA ../mix/mix-count-4k ../mix/mix-Pagecache-50out 4096)\t$(DA ../mix/mix-count-4k ../mix/mix-Pagecache-25out 4096)\t$(DA ../mix/mix-count-4k ../mix/mix-Pagecache-10out 4096)" >>  DA
	elif [[ $i == UniMem ]]; then
	    echo -e "$i\t$(DA ../mix/mix-count-512 ../mix/mix-Unimem-100out 512)\t$(DA ../mix/mix-count-512 ../mix/mix-Unimem-75out 512)\t$(DA ../mix/mix-count-512 ../mix/mix-Unimem-50out 512)\t$(DA ../mix/mix-count-512 ../mix/mix-Unimem-25out 512)\t$(DA ../mix/mix-count-512 ../mix/mix-Unimem-10out 512)" >>  DA
    fi
    done
    cd ../

    echo "generating results of Cache Block Size..."
    mkdir 4.5_Cache_Block_Size
    cd 4.5_Cache_Block_Size
    echo "generating Average Memory Access Time results of Redis-Rand"
    echo -e "cache_block_size\t128B\t256B\t512B\t1KB\t2KB\t4KB" > Redis-Rand-AMAT
    echo -e "AMAT\t$(UniMem_AMAT ../Redis/redis-cache_miss ../Redis/redis-Unimem-subpage-128B-10out)\t$(UniMem_AMAT ../Redis/redis-cache_miss ../Redis/redis-Unimem-subpage-256B-10out)\t$(UniMem_AMAT ../Redis/redis-cache_miss ../Redis/redis-Unimem-10out)\t$(UniMem_AMAT ../Redis/redis-cache_miss ../Redis/redis-Unimem-subpage-1k-10out)\t$(UniMem_AMAT ../Redis/redis-cache_miss ../Redis/redis-Unimem-subpage-2k-10out)\t$(UniMem_AMAT ../Redis/redis-cache_miss ../Redis/redis-Unimem-subpage-4k-10out)" >> Redis-Rand-AMAT
    echo "generating Data Amplification results of Redis-Rand"
    echo -e "local_cache_size\t128B\t256B\t512B\t1KB\t2KB\t4KB" > Redis-Rand-DA
    echo -e "DA\t$(DA ../Redis/redis-count-128 ../Redis/redis-Unimem-subpage-128B-10out 128)\t$(DA ../Redis/redis-count-256 ../Redis/redis-Unimem-subpage-256B-10out 256)\t$(DA ../Redis/redis-count-512 ../Redis/redis-Unimem-10out 512)\t$(DA ../Redis/redis-count-1k ../Redis/redis-Unimem-subpage-1k-10out 1024)\t$(DA ../Redis/redis-count-2k ../Redis/redis-Unimem-subpage-2k-10out 2048)\t$(DA ../Redis/redis-count-4k ../Redis/redis-Unimem-subpage-4k-10out 4096)" >>  Redis-Rand-DA
    echo "generating Average Memory Access Time results of Facebook-ETC"
    echo -e "cache_block_size\t128B\t256B\t512B\t1KB\t2KB\t4KB" > Facebook-ETC-AMAT
    echo -e "AMAT\t$(UniMem_AMAT ../Memcache/memcache-cache_miss ../Memcache/memcache-Unimem-subpage-128B-10out)\t$(UniMem_AMAT ../Memcache/memcache-cache_miss ../Memcache/memcache-Unimem-subpage-256B-10out)\t$(UniMem_AMAT ../Memcache/memcache-cache_miss ../Memcache/memcache-Unimem-10out)\t$(UniMem_AMAT ../Memcache/memcache-cache_miss ../Memcache/memcache-Unimem-subpage-1k-10out)\t$(UniMem_AMAT ../Memcache/memcache-cache_miss ../Memcache/memcache-Unimem-subpage-2k-10out)\t$(UniMem_AMAT ../Memcache/memcache-cache_miss ../Memcache/memcache-Unimem-subpage-4k-10out)" >> Facebook-ETC-AMAT
    echo "generating Data Amplification results of Facebook-ETC"
    echo -e "local_cache_size\t128B\t256B\t512B\t1KB\t2KB\t4KB" > Facebook-ETC-DA
    echo -e "DA\t$(DA ../Memcache/memcache-count-128 ../Memcache/memcache-Unimem-subpage-128B-10out 128)\t$(DA ../Memcache/memcache-count-256 ../Memcache/memcache-Unimem-subpage-256B-10out 256)\t$(DA ../Memcache/memcache-count-512 ../Memcache/memcache-Unimem-10out 512)\t$(DA ../Memcache/memcache-count-1k ../Memcache/memcache-Unimem-subpage-1k-10out 1024)\t$(DA ../Memcache/memcache-count-2k ../Memcache/memcache-Unimem-subpage-2k-10out 2048)\t$(DA ../Memcache/memcache-count-4k ../Memcache/memcache-Unimem-subpage-4k-10out 4096)" >>  Facebook-ETC-DA
    echo "generating Average Memory Access Time results of Page-Rank"
    echo -e "cache_block_size\t128B\t256B\t512B\t1KB\t2KB\t4KB" > Page-Rank-AMAT
    echo -e "AMAT\t$(UniMem_AMAT ../Pagerank/pagerank-cache_miss ../Pagerank/pagerank-Unimem-subpage-128B-10out)\t$(UniMem_AMAT ../Pagerank/pagerank-cache_miss ../Pagerank/pagerank-Unimem-subpage-256B-10out)\t$(UniMem_AMAT ../Pagerank/pagerank-cache_miss ../Pagerank/pagerank-Unimem-10out)\t$(UniMem_AMAT ../Pagerank/pagerank-cache_miss ../Pagerank/pagerank-Unimem-subpage-1k-10out)\t$(UniMem_AMAT ../Pagerank/pagerank-cache_miss ../Pagerank/pagerank-Unimem-subpage-2k-10out)\t$(UniMem_AMAT ../Pagerank/pagerank-cache_miss ../Pagerank/pagerank-Unimem-subpage-4k-10out)" >> Page-Rank-AMAT
    echo "generating Data Amplification results of Page-Rank"
    echo -e "local_cache_size\t128B\t256B\t512B\t1KB\t2KB\t4KB" > Page-Rank-DA
    echo -e "DA\t$(DA ../Pagerank/pagerank-count-128 ../Pagerank/pagerank-Unimem-subpage-128B-10out 128)\t$(DA ../Pagerank/pagerank-count-256 ../Pagerank/pagerank-Unimem-subpage-256B-10out 256)\t$(DA ../Pagerank/pagerank-count-512 ../Pagerank/pagerank-Unimem-10out 512)\t$(DA ../Pagerank/pagerank-count-1k ../Pagerank/pagerank-Unimem-subpage-1k-10out 1024)\t$(DA ../Pagerank/pagerank-count-2k ../Pagerank/pagerank-Unimem-subpage-2k-10out 2048)\t$(DA ../Pagerank/pagerank-count-4k ../Pagerank/pagerank-Unimem-subpage-4k-10out 4096)" >>  Page-Rank-DA
    echo "generating Average Memory Access Time results of YCSB-A"
    echo -e "cache_block_size\t128B\t256B\t512B\t1KB\t2KB\t4KB" > YCSB-A-AMAT
    echo -e "AMAT\t$(UniMem_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Unimem-subpage-128B-10out)\t$(UniMem_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Unimem-subpage-256B-10out)\t$(UniMem_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Unimem-10out)\t$(UniMem_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Unimem-subpage-1k-10out)\t$(UniMem_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Unimem-subpage-2k-10out)\t$(UniMem_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Unimem-subpage-4k-10out)" >> YCSB-A-AMAT
    echo "generating Data Amplification results of YCSB-A"
    echo -e "local_cache_size\t128B\t256B\t512B\t1KB\t2KB\t4KB" > YCSB-A-DA
    echo -e "DA\t$(DA ../YCSB-A/ycsb_a-count-128 ../YCSB-A/ycsb_a-Unimem-subpage-128B-10out 128)\t$(DA ../YCSB-A/ycsb_a-count-256 ../YCSB-A/ycsb_a-Unimem-subpage-256B-10out 256)\t$(DA ../YCSB-A/ycsb_a-count-512 ../YCSB-A/ycsb_a-Unimem-10out 512)\t$(DA ../YCSB-A/ycsb_a-count-1k ../YCSB-A/ycsb_a-Unimem-subpage-1k-10out 1024)\t$(DA ../YCSB-A/ycsb_a-count-2k ../YCSB-A/ycsb_a-Unimem-subpage-2k-10out 2048)\t$(DA ../YCSB-A/ycsb_a-count-4k ../YCSB-A/ycsb_a-Unimem-subpage-4k-10out 4096)" >>  YCSB-A-DA
    cd ../

    echo "generating results of Host Memory Capacity..."
    mkdir  4.6_Host_Memory_Capacity
    cd 4.6_Host_Memory_Capacity
    echo -e "host_memory_capacity\t0\t10%\t20%\t30%\t40%\t50%\t60%\t70%\t80%" > Host_Memory_Capacity-AMAT
    echo -e "Redis-Rand\t$(UniMem_NoPromote_AMAT ../Redis/redis-cache_miss ../Redis/redis-Unimem-nopromote-10out)\t$(UniMem_AMAT ../Redis/redis-cache_miss ../Redis/redis-Unimem-9-1-10out)\t$(UniMem_AMAT ../Redis/redis-cache_miss ../Redis/redis-Unimem-8-2-10out)\t$(UniMem_AMAT ../Redis/redis-cache_miss ../Redis/redis-Unimem-7-3-10out)\t$(UniMem_AMAT ../Redis/redis-cache_miss ../Redis/redis-Unimem-6-4-10out)\t$(UniMem_AMAT ../Redis/redis-cache_miss ../Redis/redis-Unimem-5-5-10out)\t$(UniMem_AMAT ../Redis/redis-cache_miss ../Redis/redis-Unimem-4-6-10out)\t$(UniMem_AMAT ../Redis/redis-cache_miss ../Redis/redis-Unimem-3-7-10out)\t$(UniMem_AMAT ../Redis/redis-cache_miss ../Redis/redis-Unimem-2-8-10out)" >> Host_Memory_Capacity-AMAT
    echo -e "Page-Rank\t$(UniMem_NoPromote_AMAT ../Pagerank/pagerank-cache_miss ../Pagerank/pagerank-Unimem-nopromote-10out)\t$(UniMem_AMAT ../Pagerank/pagerank-cache_miss ../Pagerank/pagerank-Unimem-9-1-10out)\t$(UniMem_AMAT ../Pagerank/pagerank-cache_miss ../Pagerank/pagerank-Unimem-8-2-10out)\t$(UniMem_AMAT ../Pagerank/pagerank-cache_miss ../Pagerank/pagerank-Unimem-7-3-10out)\t$(UniMem_AMAT ../Pagerank/pagerank-cache_miss ../Pagerank/pagerank-Unimem-6-4-10out)\t$(UniMem_AMAT ../Pagerank/pagerank-cache_miss ../Pagerank/pagerank-Unimem-5-5-10out)\t$(UniMem_AMAT ../Pagerank/pagerank-cache_miss ../Pagerank/pagerank-Unimem-4-6-10out)\t$(UniMem_AMAT ../Pagerank/pagerank-cache_miss ../Pagerank/pagerank-Unimem-3-7-10out)\t$(UniMem_AMAT ../Pagerank/pagerank-cache_miss ../Pagerank/pagerank-Unimem-2-8-10out)" >> Host_Memory_Capacity-AMAT
    echo -e "Facebook-ETC\t$(UniMem_NoPromote_AMAT ../Memcache/memcache-cache_miss ../Memcache/memcache-Unimem-nopromote-10out)\t$(UniMem_AMAT ../Memcache/memcache-cache_miss ../Memcache/memcache-Unimem-9-1-10out)\t$(UniMem_AMAT ../Memcache/memcache-cache_miss ../Memcache/memcache-Unimem-8-2-10out)\t$(UniMem_AMAT ../Memcache/memcache-cache_miss ../Memcache/memcache-Unimem-7-3-10out)\t$(UniMem_AMAT ../Memcache/memcache-cache_miss ../Memcache/memcache-Unimem-6-4-10out)\t$(UniMem_AMAT ../Memcache/memcache-cache_miss ../Memcache/memcache-Unimem-5-5-10out)\t$(UniMem_AMAT ../Memcache/memcache-cache_miss ../Memcache/memcache-Unimem-4-6-10out)\t$(UniMem_AMAT ../Memcache/memcache-cache_miss ../Memcache/memcache-Unimem-3-7-10out)\t$(UniMem_AMAT ../Memcache/memcache-cache_miss ../Memcache/memcache-Unimem-2-8-10out)" >> Host_Memory_Capacity-AMAT
    echo -e "YCSB-A\t$(UniMem_NoPromote_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Unimem-nopromote-10out)\t$(UniMem_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Unimem-9-1-10out)\t$(UniMem_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Unimem-8-2-10out)\t$(UniMem_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Unimem-7-3-10out)\t$(UniMem_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Unimem-6-4-10out)\t$(UniMem_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Unimem-5-5-10out)\t$(UniMem_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Unimem-4-6-10out)\t$(UniMem_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Unimem-3-7-10out)\t$(UniMem_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Unimem-2-8-10out)" >> Host_Memory_Capacity-AMAT
    cd ../

    echo "generating results of Set Associativity..."
    mkdir 4.7_Set_Associativity
    cd 4.7_Set_Associativity
    echo -e "Set Associativity\t1\t4\t8\t16" > Set_Associativity-AMAT
    echo "generating Average Memory Access Time results of Redis-Rand"
    echo -e "Redis-Rand\t$(UniMem_AMAT ../Redis/redis-cache_miss ../Redis/redis-Unimem-10out)\t$(UniMem_AMAT ../Redis/redis-cache_miss ../Redis/redis-Unimem-4set-10out)\t$(UniMem_AMAT ../Redis/redis-cache_miss ../Redis/redis-Unimem-8set-10out)\t$(UniMem_AMAT ../Redis/redis-cache_miss ../Redis/redis-Unimem-16set-10out)" >> Set_Associativity-AMAT
    echo "generating Average Memory Access Time results of Facebook-ETC"
    echo -e "Facebook-ETC\t$(UniMem_AMAT ../Memcache/memcache-cache_miss ../Memcache/memcache-Unimem-10out)\t$(UniMem_AMAT ../Memcache/memcache-cache_miss ../Memcache/memcache-Unimem-4set-10out)\t$(UniMem_AMAT ../Memcache/memcache-cache_miss ../Memcache/memcache-Unimem-8set-10out)\t$(UniMem_AMAT ../Memcache/memcache-cache_miss ../Memcache/memcache-Unimem-16set-10out)" >> Set_Associativity-AMAT
    echo "generating Average Memory Access Time results of Page-Rank"
    echo -e "Page-Rank\t$(UniMem_AMAT ../Pagerank/pagerank-cache_miss ../Pagerank/pagerank-Unimem-10out)\t$(UniMem_AMAT ../Pagerank/pagerank-cache_miss ../Pagerank/pagerank-Unimem-4set-10out)\t$(UniMem_AMAT ../Pagerank/pagerank-cache_miss ../Pagerank/pagerank-Unimem-8set-10out)\t$(UniMem_AMAT ../Pagerank/pagerank-cache_miss ../Pagerank/pagerank-Unimem-16set-10out)" >> Set_Associativity-AMAT
    echo "generating Average Memory Access Time results of YCSB-A"
    echo -e "YCSB-A\t$(UniMem_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Unimem-10out)\t$(UniMem_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Unimem-4set-10out)\t$(UniMem_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Unimem-8set-10out)\t$(UniMem_AMAT ../YCSB-A/ycsb_a-cache_miss ../YCSB-A/ycsb_a-Unimem-16set-10out)" >> Set_Associativity-AMAT

    echo -e "Set Associativity\t1\t4\t8\t16" > Set_Associativity-DA
    echo "generating Data Amplification results of Redis-Rand"
    echo -e "Redis-Rand\t$(DA ../Redis/redis-count-512 ../Redis/redis-Unimem-10out 512)\t$(DA ../Redis/redis-count-512 ../Redis/redis-Unimem-4set-10out 512)\t$(DA ../Redis/redis-count-512 ../Redis/redis-Unimem-8set-10out 512)\t$(DA ../Redis/redis-count-512 ../Redis/redis-Unimem-16set-10out 512)" >>  Set_Associativity-DA
    echo "generating Data Amplification results of Facebook-ETC"
    echo -e "Facebook-ETC\t$(DA ../Memcache/memcache-count-512 ../Memcache/memcache-Unimem-10out 512)\t$(DA ../Memcache/memcache-count-512 ../Memcache/memcache-Unimem-4set-10out 512)\t$(DA ../Memcache/memcache-count-512 ../Memcache/memcache-Unimem-8set-10out 512)\t$(DA ../Memcache/memcache-count-512 ../Memcache/memcache-Unimem-16set-10out 512)" >>  Set_Associativity-DA
    echo "generating Data Amplification results of Page-Rank"
    echo -e "Page-Rank\t$(DA ../Pagerank/pagerank-count-512 ../Pagerank/pagerank-Unimem-10out 512)\t$(DA ../Pagerank/pagerank-count-512 ../Pagerank/pagerank-Unimem-4set-10out 512)\t$(DA ../Pagerank/pagerank-count-512 ../Pagerank/pagerank-Unimem-8set-10out 512)\t$(DA ../Pagerank/pagerank-count-512 ../Pagerank/pagerank-Unimem-16set-10out 512)" >>  Set_Associativity-DA
    echo "generating Data Amplification results of YCSB-A"
    echo -e "YCSB-A\t$(DA ../YCSB-A/ycsb_a-count-512 ../YCSB-A/ycsb_a-Unimem-10out 512)\t$(DA ../YCSB-A/ycsb_a-count-512 ../YCSB-A/ycsb_a-Unimem-4set-10out 512)\t$(DA ../YCSB-A/ycsb_a-count-512 ../YCSB-A/ycsb_a-Unimem-8set-10out 512)\t$(DA ../YCSB-A/ycsb_a-count-512 ../YCSB-A/ycsb_a-Unimem-16set-10out 512)" >>  Set_Associativity-DA
    cd ../
    
