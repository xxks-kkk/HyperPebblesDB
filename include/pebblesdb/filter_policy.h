// Copyright (c) 2012 The LevelDB Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file. See the AUTHORS file for names of contributors.
//
// A database can be configured with a custom FilterPolicy object.
// This object is responsible for creating a small filter from a set
// of keys.  These filters are stored in leveldb and are consulted
// automatically by leveldb to decide whether or not to read some
// information from disk. In many cases, a filter can cut down the
// number of disk seeks form a handful to a single disk seek per
// DB::Get() call.
//
// Most people will want to use the builtin bloom filter support (see
// NewBloomFilterPolicy() below).

#ifndef STORAGE_LEVELDB_INCLUDE_FILTER_POLICY_H_
#define STORAGE_LEVELDB_INCLUDE_FILTER_POLICY_H_

#include <memory>
#include <stdexcept>
#include <stdlib.h>
#include <string>
#include <vector>


namespace leveldb {

class Slice;

// A class that takes a bunch of keys, then generates filter
class FilterBitsBuilder {
 public:
  virtual ~FilterBitsBuilder() {}

  // Add Key to filter, you could use any way to store the key.
  // Such as: storing hashes or original keys
  // Keys are in sorted order and duplicated keys are possible.
  virtual void AddKey(const Slice& key) = 0;

  // Generate the filter using the keys that are added
  // The return value of this function would be the filter bits,
  // The ownership of actual data is set to buf
  virtual Slice Finish(std::unique_ptr<const char[]>* buf) = 0;

  // Calculate num of entries fit into a space.
#if defined(_MSC_VER)
#pragma warning(push)
#pragma warning(disable : 4702) // unreachable code
#endif
  virtual int CalculateNumEntry(const uint32_t /*space*/) {
#ifndef ROCKSDB_LITE
    throw std::runtime_error("CalculateNumEntry not Implemented");
#else
    abort();
#endif
    return 0;
  }
#if defined(_MSC_VER)
#pragma warning(pop)
#endif
};

// A class that checks if a key can be in filter
// It should be initialized by Slice generated by BitsBuilder
class FilterBitsReader {
 public:
  virtual ~FilterBitsReader() {}

  // Check if the entry match the bits in filter
  virtual bool MayMatch(const Slice& entry) = 0;

   // huanchen
  //  virtual Slice Seek(const Slice& entry, unsigned* bitlen, const bool inclusive) {
  //      return Slice();
  // }

  //  // huanchen
  //  virtual Slice SeekForPrev(const Slice& entry, unsigned* bitlen, const bool inclusive) {  
  //      return Slice();
  // }
};


class FilterPolicy {
 public:
  virtual ~FilterPolicy();

  // Return the name of this policy.  Note that if the filter encoding
  // changes in an incompatible way, the name returned by this method
  // must be changed.  Otherwise, old incompatible filters may be
  // passed to methods of this type.
  virtual const char* Name() const = 0;

  // keys[0,n-1] contains a list of keys (potentially with duplicates)
  // that are ordered according to the user supplied comparator.
  // Append a filter that summarizes keys[0,n-1] to *dst.
  //
  // Warning: do not change the initial contents of *dst.  Instead,
  // append the newly constructed filter to *dst.
  virtual void CreateFilter(const Slice* keys, int n, std::string* dst)
      const = 0;

  // "filter" contains the data appended by a preceding call to
  // CreateFilter() on this class.  This method must return true if
  // the key was in the list of keys passed to CreateFilter().
  // This method may return true or false if the key was not on the
  // list, but it should aim to return false with a high probability.
  virtual bool KeyMayMatch(const Slice& key, const Slice& filter) const = 0;

  // Get the FilterBitsBuilder, which is ONLY used for full filter block
  // It contains interface to take individual key, then generate filter
  virtual FilterBitsBuilder* GetFilterBitsBuilder() const {
    return nullptr;
  }

  // Get the FilterBitsReader, which is ONLY used for full filter block
  // It contains interface to tell if key can be in filter
  // The input slice should NOT be deleted by FilterPolicy
  virtual FilterBitsReader* GetFilterBitsReader(
      const Slice& /*contents*/) const {
    return nullptr;
  }
};

// Return a new filter policy that uses a bloom filter with approximately
// the specified number of bits per key.  A good value for bits_per_key
// is 10, which yields a filter with ~ 1% false positive rate.
//
// Callers must delete the result after any database that is using the
// result has been closed.
//
// Note: if you are using a custom comparator that ignores some parts
// of the keys being compared, you must not use NewBloomFilterPolicy()
// and must provide your own FilterPolicy that also ignores the
// corresponding parts of the keys.  For example, if the comparator
// ignores trailing spaces, it would be incorrect to use a
// FilterPolicy (like NewBloomFilterPolicy) that does not ignore
// trailing spaces in keys.
extern const FilterPolicy* NewBloomFilterPolicy(int bits_per_key);

extern const FilterPolicy* NewSuRFPolicy(int suffix_type = 0,
                                        uint32_t hash_suffix_len = 0,
                                        uint32_t real_suffic_len = 0,
                                        bool inclue_dense = true,
                                        uint32_t sparse_dense_ratio = 0,
                                        bool use_block_based_builder = true);
}

#endif  // STORAGE_LEVELDB_INCLUDE_FILTER_POLICY_H_
