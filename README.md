# UniMem
## 1 Introduction
This is the implementation of UniMem described in the paper "**UniMem: Redesigning Disaggregated Memory within A Unified Local-Remote Memory Hierarchy**". UniMem is a cache-coherent-based DM system that proposes a unified local-remote memory hierarchy to remove extra indirection layer on remote memory access path.
We gather the memory access operations, memory address and access data size of the workload using Intel Pin(https://software.intel.com/sites/landingpage/pintool/downloads/pin-3.30-98830-g1d7b601b3-gcc-linux.tar.gz)

## 2 Compilation and Run UniMem
### 2.1 Tools
UniMem execute Yahoo Cloud Serving Benchmark (YCSB) workloads(http://github.com/brianfrankcooper/YCSB).
We also take advantage of Kona(https://github.com/project-kona/apps).

### 2.2 Compilation
The GCC version in our environment is 7.5.0.
```
  $ cd tool
  $ ./setup.sh
  $ cd ..
```
You may need to manually download the Twitter-dataset and unzip it in the tool/apps/turi/ folder.

### 2.3 Run
First set the environment variables and then run the UniMem.
```
  $ cd src
  $ ./run.sh
```
The results will be saved in folders named after the experimental section of the paper.
