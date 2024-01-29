#!/bin/bash
workloads=$1
pagenum=$2

array=(100 75 50 25 10)

for i in ${array[@]}
do
	sed -i "8c #define CAPACITY $((pagenum*i/100))" /home/minqiangzhou/BIP-4k.cpp
	head /home/minqiangzhou/BIP-4k.cpp
	g++ -g -o bip-${workloads}-4k-${i}out /home/minqiangzhou/BIP-4k.cpp
    ./bip-${workloads}-4k-${i}out ${workloads}-cache_miss ${workloads}-BIP-4k-${i}out	
done


