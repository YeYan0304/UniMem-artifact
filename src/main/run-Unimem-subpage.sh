#!/bin/bash
workloads=$1
# pagenuma=$2
# pagenumb=$3
# pagenumc=$4
# pagenumd=$5
pagenume=$2

array=(100 75 50 25 10)

# for i in ${array[@]}
# do
# 	sed -i "7c #define CAPACITY $((pagenuma*i/100))" /home/minqiangzhou/BIP-subpage.cpp
# 	sed -i "8c #define SUBPAGE 0x7f" /home/minqiangzhou/BIP-subpage.cpp
# 	head -n 15 /home/minqiangzhou/BIP-subpage.cpp
# 	g++ -g -o bip-${workloads}-subpage-128B-${i}out /home/minqiangzhou/BIP-subpage.cpp
#     ./bip-${workloads}-subpage-128B-${i}out ${workloads}-cache_miss ${workloads}-BIP-subpage-128B-${i}out	
# done

# for i in ${array[@]}
# do
# 	sed -i "7c #define CAPACITY $((pagenumb*i/100))" /home/minqiangzhou/BIP-subpage.cpp
# 	sed -i "8c #define SUBPAGE 0xff" /home/minqiangzhou/BIP-subpage.cpp
# 	head -n 15 /home/minqiangzhou/BIP-subpage.cpp
# 	g++ -g -o bip-${workloads}-subpage-256B-${i}out /home/minqiangzhou/BIP-subpage.cpp
#     ./bip-${workloads}-subpage-256B-${i}out ${workloads}-cache_miss ${workloads}-BIP-subpage-256B-${i}out	
# done

# for i in ${array[@]}
# do
# 	sed -i "7c #define CAPACITY $((pagenumc*i/100))" /home/minqiangzhou/BIP-subpage.cpp
# 	sed -i "8c #define SUBPAGE 0x3ff" /home/minqiangzhou/BIP-subpage.cpp
# 	head -n 15 /home/minqiangzhou/BIP-subpage.cpp
# 	g++ -g -o bip-${workloads}-subpage-1k-${i}out /home/minqiangzhou/BIP-subpage.cpp
#     ./bip-${workloads}-subpage-1k-${i}out ${workloads}-cache_miss ${workloads}-BIP-subpage-1k-${i}out	
# done

# for i in ${array[@]}
# do
# 	sed -i "7c #define CAPACITY $((pagenumd*i/100))" /home/minqiangzhou/BIP-subpage.cpp
# 	sed -i "8c #define SUBPAGE 0x7ff" /home/minqiangzhou/BIP-subpage.cpp
# 	head -n 15 /home/minqiangzhou/BIP-subpage.cpp
# 	g++ -g -o bip-${workloads}-subpage-2k-${i}out /home/minqiangzhou/BIP-subpage.cpp
#     ./bip-${workloads}-subpage-2k-${i}out ${workloads}-cache_miss ${workloads}-BIP-subpage-2k-${i}out	
# done

for i in ${array[@]}
do
	sed -i "7c #define CAPACITY $((pagenume*i/100))" /home/minqiangzhou/BIP-subpage.cpp
	sed -i "8c #define SUBPAGE 0xfff" /home/minqiangzhou/BIP-subpage.cpp
	head -n 15 /home/minqiangzhou/BIP-subpage.cpp
	g++ -g -o bip-${workloads}-subpage-4k-${i}out /home/minqiangzhou/BIP-subpage.cpp
    ./bip-${workloads}-subpage-4k-${i}out ${workloads}-cache_miss ${workloads}-BIP-subpage-4k-${i}out	
done
