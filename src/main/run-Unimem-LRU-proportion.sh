#!/bin/bash
workloads=$1
pagenum=$2

array=(100 75 50 25 10)

for i in ${array[@]}
do
	sed -i "7c #define CAPACITY $((pagenum*i/100))" /home/minqiangzhou/BIP-proportion.cpp
	sed -i "8c #define BIP_CAPACITY CAPACITY * 8 * 0.9" /home/minqiangzhou/BIP-proportion.cpp
	sed -i "9c #define LRU_CAPACITY CAPACITY * 0.1" /home/minqiangzhou/BIP-proportion.cpp
	head /home/minqiangzhou/BIP-proportion.cpp
	g++ -g -o bip-${workloads}-9-1-${i}out /home/minqiangzhou/BIP-proportion.cpp
    ./bip-${workloads}-9-1-${i}out ${workloads}-cache_miss ${workloads}-BIP-9-1-${i}out	
done

for i in ${array[@]}
do
	sed -i "7c #define CAPACITY $((pagenum*i/100))" /home/minqiangzhou/BIP-proportion.cpp
	sed -i "8c #define BIP_CAPACITY CAPACITY * 8 * 0.8" /home/minqiangzhou/BIP-proportion.cpp
	sed -i "9c #define LRU_CAPACITY CAPACITY * 0.2" /home/minqiangzhou/BIP-proportion.cpp
	head /home/minqiangzhou/BIP-proportion.cpp
	g++ -g -o bip-${workloads}-8-2-${i}out /home/minqiangzhou/BIP-proportion.cpp
    ./bip-${workloads}-8-2-${i}out ${workloads}-cache_miss ${workloads}-BIP-8-2-${i}out	
done

for i in ${array[@]}
do
	sed -i "7c #define CAPACITY $((pagenum*i/100))" /home/minqiangzhou/BIP-proportion.cpp
	sed -i "8c #define BIP_CAPACITY CAPACITY * 8 * 0.7" /home/minqiangzhou/BIP-proportion.cpp
	sed -i "9c #define LRU_CAPACITY CAPACITY * 0.3" /home/minqiangzhou/BIP-proportion.cpp
	head /home/minqiangzhou/BIP-proportion.cpp
	g++ -g -o bip-${workloads}-7-3-${i}out /home/minqiangzhou/BIP-proportion.cpp
    ./bip-${workloads}-7-3-${i}out ${workloads}-cache_miss ${workloads}-BIP-7-3-${i}out	
done

for i in ${array[@]}
do
	sed -i "7c #define CAPACITY $((pagenum*i/100))" /home/minqiangzhou/BIP-proportion.cpp
	sed -i "8c #define BIP_CAPACITY CAPACITY * 8 * 0.6" /home/minqiangzhou/BIP-proportion.cpp
	sed -i "9c #define LRU_CAPACITY CAPACITY * 0.4" /home/minqiangzhou/BIP-proportion.cpp
	head /home/minqiangzhou/BIP-proportion.cpp
	g++ -g -o bip-${workloads}-6-4-${i}out /home/minqiangzhou/BIP-proportion.cpp
    ./bip-${workloads}-6-4-${i}out ${workloads}-cache_miss ${workloads}-BIP-6-4-${i}out	
done

for i in ${array[@]}
do
	sed -i "7c #define CAPACITY $((pagenum*i/100))" /home/minqiangzhou/BIP-proportion.cpp
	sed -i "8c #define BIP_CAPACITY CAPACITY * 8 * 0.5" /home/minqiangzhou/BIP-proportion.cpp
	sed -i "9c #define LRU_CAPACITY CAPACITY * 0.5" /home/minqiangzhou/BIP-proportion.cpp
	head /home/minqiangzhou/BIP-proportion.cpp
	g++ -g -o bip-${workloads}-5-5-${i}out /home/minqiangzhou/BIP-proportion.cpp
    ./bip-${workloads}-5-5-${i}out ${workloads}-cache_miss ${workloads}-BIP-5-5-${i}out	
done

for i in ${array[@]}
do
	sed -i "7c #define CAPACITY $((pagenum*i/100))" /home/minqiangzhou/BIP-proportion.cpp
	sed -i "8c #define BIP_CAPACITY CAPACITY * 8 * 0.4" /home/minqiangzhou/BIP-proportion.cpp
	sed -i "9c #define LRU_CAPACITY CAPACITY * 0.6" /home/minqiangzhou/BIP-proportion.cpp
	head /home/minqiangzhou/BIP-proportion.cpp
	g++ -g -o bip-${workloads}-4-6-${i}out /home/minqiangzhou/BIP-proportion.cpp
    ./bip-${workloads}-4-6-${i}out ${workloads}-cache_miss ${workloads}-BIP-4-6-${i}out	
done

for i in ${array[@]}
do
	sed -i "7c #define CAPACITY $((pagenum*i/100))" /home/minqiangzhou/BIP-proportion.cpp
	sed -i "8c #define BIP_CAPACITY CAPACITY * 8 * 0.3" /home/minqiangzhou/BIP-proportion.cpp
	sed -i "9c #define LRU_CAPACITY CAPACITY * 0.7" /home/minqiangzhou/BIP-proportion.cpp
	head /home/minqiangzhou/BIP-proportion.cpp
	g++ -g -o bip-${workloads}-3-7-${i}out /home/minqiangzhou/BIP-proportion.cpp
    ./bip-${workloads}-3-7-${i}out ${workloads}-cache_miss ${workloads}-BIP-3-7-${i}out	
done

for i in ${array[@]}
do
	sed -i "7c #define CAPACITY $((pagenum*i/100))" /home/minqiangzhou/BIP-proportion.cpp
	sed -i "8c #define BIP_CAPACITY CAPACITY * 8 * 0.2" /home/minqiangzhou/BIP-proportion.cpp
	sed -i "9c #define LRU_CAPACITY CAPACITY * 0.8" /home/minqiangzhou/BIP-proportion.cpp
	head /home/minqiangzhou/BIP-proportion.cpp
	g++ -g -o bip-${workloads}-2-8-${i}out /home/minqiangzhou/BIP-proportion.cpp
    ./bip-${workloads}-2-8-${i}out ${workloads}-cache_miss ${workloads}-BIP-2-8-${i}out	
done
