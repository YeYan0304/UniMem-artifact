#!/bin/bash
workloads=$1
pagenum=$2

array=(100 75 50 25 10)

for i in ${array[@]}
do
	sed -i "7c #define CAPACITY $((pagenum*i/100))" /home/minqiangzhou/BIP.cpp
	sed -i "13c #define SUBPAGE 0x1ff" /home/minqiangzhou/BIP.cpp
	head /home/minqiangzhou/BIP.cpp
	g++ -g -o bip-${workloads}-${i}out /home/minqiangzhou/BIP.cpp
    ./bip-${workloads}-${i}out ${workloads}-cache_miss ${workloads}-BIP-${i}out	
done


