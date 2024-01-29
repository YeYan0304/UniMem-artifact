#!/bin/bash
workloads=$1
pagenum=$2

array=(100 75 50 25 10)

for i in ${array[@]}
do
	sed -i "6c #define INDEX $((pagenum*i/4/100))" /home/minqiangzhou/FIFO.cpp
	head /home/minqiangzhou/FIFO.cpp
	g++ -g -o fifo-${workloads}-${i}out /home/minqiangzhou/FIFO.cpp
        ./fifo-${workloads}-${i}out ${workloads}-cache_miss ${workloads}-FIFO-${i}out	
done


