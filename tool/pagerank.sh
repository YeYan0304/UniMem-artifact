#!/bin/bash
arg=$1
MAX_FILE_SIZE=$((arg * 1024 * 1024 * 1024))

    #Generate memory access sequence of pagerank 
    cd apps/turi/
    ./app_graph_analytics.py -g twitter -a pagerank &
    sleep 20s
    pid_pagerank=$!
    while :; do
        if ! kill -0 $pid_pagerank 2>/dev/null; then
            echo "pagerank finished"
            break
        else
            FILE_SIZE=$(stat -c%s "pinatrace.out" 2>/dev/null)
            if [ $? -eq 0 ] && [ "$FILE_SIZE" -gt "$MAX_FILE_SIZE" ];then
                kill -9 $pid_pagerank
                sleep 1s
                if ! kill -0 $pid_pagerank 2>/dev/null; then
                    echo "pagerank reach max file size"
                    break
                fi
            fi
            sleep 1s
        fi
    done
    mkdir ../../../src/Pagerank
    mv pinatrace.out ../../../src/Pagerank/pagerank.out
    cd ../../
