cmake_minimum_required(VERSION 3.9)
project(pebblesdb)

set(CMAKE_CXX_STANDARD 11)

include_directories(.)
include_directories(db)
include_directories(doc)
include_directories(doc/bench)
include_directories(helpers)
include_directories(helpers/memenv)
include_directories(include)
include_directories(include/pebblesdb)
include_directories(issues)
include_directories(port)
include_directories(table)
include_directories(util)

include(CheckLibraryExists)
check_library_exists(snappy snappy_compress "" HAVE_SNAPPY)

# Make 'libpebblesdb' static library
add_library(libpebblesdb STATIC
        port/port_posix.cc
        port/port_posix.h
        port/port_stdcxx.h
        port/port.h
        db/builder.cc
        db/c.cc
        db/dbformat.cc
        db/db_impl.cc
        db/db_iter.cc
        db/filename.cc
        db/log_reader.cc
        db/log_writer.cc
        db/memtable.cc
        db/murmurhash3.cc
        db/repair.cc
        db/replay_iterator.cc
        db/table_cache.cc
        db/version_edit.cc
        db/version_set.cc
        db/write_batch.cc
        table/block.cc
        table/block_builder.cc
        table/filter_block.cc
        table/format.cc
        table/iterator.cc
        table/merger.cc
        table/table_builder.cc
        table/table.cc
        table/two_level_iterator.cc
        util/arena.cc
        util/atomic.cc
        util/bloom.cc
        util/cache.cc
        util/coding.cc
        util/comparator.cc
        util/crc32c.cc
        util/env.cc
        util/env_posix.cc
        util/filter_policy.cc
        util/hash.cc
        util/histogram.cc
        util/logging.cc
        util/options.cc
        util/status.cc)

include(TestBigEndian)
test_big_endian(LEVELDB_IS_BIG_ENDIAN)

# Check the existance of snappy
if(HAVE_SNAPPY)
    target_link_libraries(libpebblesdb snappy)
endif(HAVE_SNAPPY)

# Check pthread
set(THREADS_PREFER_PTHREAD_FLAG ON)
find_package(Threads REQUIRED)
target_link_libraries(libpebblesdb Threads::Threads)

# Make 'testPebblesDB' executable
add_executable(testPebblesDB
        learning/testPebblesDB.cc)
target_link_libraries(testPebblesDB
        Threads::Threads
        libpebblesdb)