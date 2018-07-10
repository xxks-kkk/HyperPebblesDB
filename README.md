## HyperPebblesDB 

[![Build Status](https://travis-ci.org/xxks-kkk/HyperPebblesDB.svg?branch=master)](https://travis-ci.org/xxks-kkk/HyperPebblesDB)

HyperPebblesDB is a key-value store that is part of [LevelDB](https://github.com/google/leveldb) family.
It is API-compatible with LevelDB and [HyperLevelDB](https://github.com/rescrv/HyperLevelDB).

HyperPebblesDB is a spin-off of [PebblesDB](https://github.com/utsaslab/pebblesdb), a write-optimized key-value store built
with FLSM (Fragmented Log-Structured Merge Tree) data structure. FLSM is a modification of the standard log-structured
merge tree data structure which aims at achieving higher write throughput and lower write amplification
without compromising on read throughput. Please read [full paper on PebblesDB](http://www.cs.utexas.edu/~vijay/papers/sosp17-pebblesdb.pdf)
and corresponding [slides](http://www.cs.utexas.edu/~vijay/papers/pebblesdb-sosp17-slides.pdf) for further details.


## Philosophy

Why maintain HyperPebblesDB? One argument people always use is that from research point of view, you can hardly get anything
good out of it (e.g. paper). Well, Prof. Michael Stonebraker's Postgres will be considered out-of-place in today's research
environment: ["Way too much work for too few publications"](https://youtu.be/DJFKl_5JTnA). However, I think
Postgres's success really lies in the tremendous effort done on the implementation side. Also, Prof. John Ousterhout views
the discard of research prototype as a waste of effort (Check out [how much effort](https://ramcloud.atlassian.net/wiki/spaces/RAM/pages/19726351/Group+Photos)
Prof. John Ousterhout and his group devote to build [RAMCloud](https://web.stanford.edu/~ouster/cgi-bin/papers/ramcloud.pdf).
I simply agree with them.

From practical point of view, this project serves me well for the following purpose:

- Improve my competency to work with a relative complex project
- A robust testbed for LevelDB-related research projects


### Installation

The project supports [CMake](https://cmake.org/) out of the box. To get started

```bash
mkdir -p build && cd build
cmake --build .
```