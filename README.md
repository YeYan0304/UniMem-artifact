# UniMem
## 1 Introduction
This is the implementation of UniMem described in the paper "**UniMem: Redesigning Disaggregated Memory within A Unified Local-Remote Memory Hierarchy**". UniMem is a cache-coherent-based DM system that proposes a unified local-remote memory hierarchy to remove extra indirection layer on remote memory access path.
We implement CacheKV based on [NoveLSM] (https://github.com/sudarsunkannan/lsm_nvm).

## 2 Compilation and Run CacheKV
### 2.1 Tools
CacheKV relies on Intel(R) RDT Software Package (https://github.com/intel/intel-cmt-cat).
To run CacheKV, please install it first (https://github.com/intel/intel-cmt-cat/blob/master/INSTALL).

### 2.2 Compilation
The GCC version in our environment is 7.5.0.
```
  $ cd hoard
  $ ./compile_install_hoard.sh
  $ cd ..
  $ make -j8
```

### 2.3 Run
First set the environment variables and then run the DB_Bench benchmark.
```
  $ source scripts/setvars.sh
  $ scripts/run_cachekv_dbbench.sh
```
