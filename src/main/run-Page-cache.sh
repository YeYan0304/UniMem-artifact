#!/bin/bash
workloads=$1
pagenum=$2

array=(100 75 50 25 10)

for i in ${array[@]}
do
	sed -i "4c #define CAPACITY $((pagenum*i/100))" /home/minqiangzhou/LRU.cpp
	head /home/minqiangzhou/LRU.cpp
	g++ -g -o lru-${workloads}-${i}out /home/minqiangzhou/LRU.cpp
        ./lru-${workloads}-${i}out ${workloads}-cache_miss ${workloads}-LRU-${i}out	
done


