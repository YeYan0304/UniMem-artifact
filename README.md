# Paper#51

## Instructions
UniMem is implemented in simulation. We use Intel Pin tool to gather the memory access operations of workloads and simulate their run in our system. The workloads include Facebook-ETC, Redis-Rand, YCSB-A/B, Page Rank and Linear Regression in our experiments. These instructions have been tested on a clean Ubuntu 20.04.6 LTS (GNU/Linux 5.4.0-177-generic x86_64).

Clone the repository
```
git clone https://github.com/YeYan0304/atc24-ae
cd atc24-ae
```

## Setup and Run
### Setup
We first install the Intel Pin tool. Second, we install redis, memcached, YCSB, Mutilate (for Facebook-ETC) for running workloads. We also download the dataset (Twitter-dataset.zip) for Page Rank. Then, we run the workloads with Intel Pin to gather the memory access address and data size.

You need to execute setup.sh in **root** user.

```
cd tool
./setup.sh
```

#### NOTE: 

1. The "setup.sh" script would take a few times.
2. You may need to manually download the Twitter-dataset and unzip it in the tool/apps/turi/ folder.
```
wget https://archive.org/download/asu_twitter_dataset/Twitter-dataset.zip
mv Twitter-dataset.zip /your/path/atc24-ae/tool/apps/turi/
unzip Twitter-dataset.zip
```
3. To compile mutilate correctly, you may need to modify the print statement format in the SConstruct file.
4. You might get the following error when generating memory access sequence of YCSB-A and YCSB-B: `ERROR: a redis.clients.jedis.exceptions.JedisConnectionException: java.net.SocketTimeoutException: Read timed out.`When this error occurs, you may need to rerun the program several times.

### Run
First set the environment variables and then run the UniMem.

You also need to execute run.sh in **root** user.
```
cd src
./run.sh
```

#### NOTE: 

1. The results will be saved in folders named after the experimental section of the paper.
2. The "run.sh" script would take a few times.
