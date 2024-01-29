#!/bin/bash
workloads=$1
pagenum=$2

array1=(100 75 50 25 10)

for i in ${array1[@]}
do
	sed -i "8c #define INDEX 0x7" /home/minqiangzhou/BIP-set.cpp
	sed -i "7c #define CAPACITY $((pagenum*i/100))" /home/minqiangzhou/BIP-set.cpp
	head /home/minqiangzhou/BIP-set.cpp
	g++ -g -o bip-${workloads}-8set-${i}out /home/minqiangzhou/BIP-set.cpp
    ./bip-${workloads}-8set-${i}out ${workloads}-cache_miss ${workloads}-BIP-8set-${i}out	
done

array=(50 25 10)

for i in ${array[@]}
do
	sed -i "8c #define INDEX 0x3" /home/minqiangzhou/BIP-set.cpp
	sed -i "7c #define CAPACITY $((pagenum*i/100))" /home/minqiangzhou/BIP-set.cpp
	head /home/minqiangzhou/BIP-set.cpp
	g++ -g -o bip-${workloads}-4set-${i}out /home/minqiangzhou/BIP-set.cpp
    ./bip-${workloads}-4set-${i}out ${workloads}-cache_miss ${workloads}-BIP-4set-${i}out	
done

for i in ${array[@]}
do
	sed -i "8c #define INDEX 0xf" /home/minqiangzhou/BIP-set.cpp
	sed -i "7c #define CAPACITY $((pagenum*i/100))" /home/minqiangzhou/BIP-set.cpp
	head /home/minqiangzhou/BIP-set.cpp
	g++ -g -o bip-${workloads}-16set-${i}out /home/minqiangzhou/BIP-set.cpp
    ./bip-${workloads}-16set-${i}out ${workloads}-cache_miss ${workloads}-BIP-16set-${i}out	
done

