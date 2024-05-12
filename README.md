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

1. The "setup.sh" script would take a long time.
2. If the download of dataset is time out, you need to manually download the Twitter-dataset and unzip it in the tool/apps/turi/ folder.
```
wget https://archive.org/download/asu_twitter_dataset/Twitter-dataset.zip
mv Twitter-dataset.zip /your/path/atc24-ae/tool/apps/turi/
unzip Twitter-dataset.zip
```
3. If you meet the following error during the compiling of mutilate, you may need to modify all the print in the tool/mutilate/SConstruct file.
```
SyntaxError: Missing parentheses in call to 'print'.
```
4. If you meet the following error, you might rerun the script.
```
ERROR: a redis.clients.jedis.exceptions.JedisConnectionException: java.net.SocketTimeoutException: Read timed out.
```

### Run
First set the environment variables and then run the UniMem.

You also need to execute run.sh in **root** user.
```
cd src
./run.sh
```

#### NOTE: 

1. The "run.sh" script would take a long time.
2. The results will be saved in folders named after the experiment section (Section 4) in the paper.
