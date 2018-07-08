// Copyright (c) 2012 The LevelDB Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file. See the AUTHORS file for names of contributors.
//
// A filter block is stored near the end of a Table file.  It contains
// filters (e.g., bloom filters) for all data blocks in the table combined
// into a single filter block.

#ifndef STORAGE_LEVELDB_TABLE_FILTER_BLOCK_H_
#define STORAGE_LEVELDB_TABLE_FILTER_BLOCK_H_

#include <stddef.h>
#include <stdint.h>
#include <string>
#include <vector>
#include <memory>
#include <limits.h> 
#include "pebblesdb/slice.h"
#include "util/hash.h"
#include "util/string_builder.h"
#include "format.h"

namespace leveldb {

class FilterPolicy;
const uint64_t kNotValid = ULLONG_MAX;

class FileLevelFilterBuilder {
 public:
  explicit FileLevelFilterBuilder(const FilterPolicy*);
  ~FileLevelFilterBuilder();

  void AddKey(const Slice& key);
  void Clear();
  void Destroy();
  std::string* GenerateFilter();

 private:

  const FilterPolicy* policy_;
  StringBuilder keys_;            // Flattened key contents
  std::vector<size_t> key_offsets_;     // Starting index in keys_ of each key
  std::vector<Slice> tmp_keys_;   // policy_->CreateFilter() argument

  // No copying allowed
  FileLevelFilterBuilder(const FileLevelFilterBuilder&);
  void operator=(const FileLevelFilterBuilder&);
};

// A FilterBlockBuilder is used to construct all of the filters for a
// particular Table.  It generates a single string which is stored as
// a special block in the Table.
//
// The sequence of calls to FilterBlockBuilder must match the regexp:
//      (StartBlock AddKey*)* Finish
class FilterBlockBuilder {
 public:
  explicit FilterBlockBuilder(const FilterPolicy*);

  void StartBlock(uint64_t block_offset);
  void AddKey(const Slice& key);
  Slice Finish();

 private:
  void GenerateFilter();

  const FilterPolicy* policy_;
  StringBuilder keys_;            // Flattened key contents
  std::vector<size_t> start_;     // Starting index in keys_ of each key
  std::string result_;            // Filter data computed so far
  std::vector<Slice> tmp_keys_;   // policy_->CreateFilter() argument
  std::vector<uint32_t> filter_offsets_;

  // No copying allowed
  FilterBlockBuilder(const FilterBlockBuilder&);
  void operator=(const FilterBlockBuilder&);
};

class FilterBlockReader {
 public:
 // REQUIRES: "contents" and *policy must stay live while *this is live.
  FilterBlockReader(const FilterPolicy* policy, const Slice& contents);
  bool KeyMayMatch(uint64_t block_offset, const Slice& key);
    // huanchen
  // virtual Slice Seek(const Slice& key, unsigned* bitlen, const bool inclusive,
	// 	     uint64_t block_offset = kNotValid,
	// 	     const bool no_io = false,
	// 	     const Slice* const const_ikey_ptr = nullptr) {
  //     return Slice();
  // }

  // // huanchen
  // virtual Slice SeekForPrev(const Slice& key, unsigned* bitlen, const bool inclusive,
	// 		    uint64_t block_offset = kNotValid,
	// 		    const bool no_io = false,
	// 		    const Slice* const const_ikey_ptr = nullptr) {
  //     return Slice();
  // }


 private:
  const FilterPolicy* policy_;
  const char* data_;    // Pointer to filter data (at block-start)
  const char* offset_;  // Pointer to beginning of offset array (at block-end)
  size_t num_;          // Number of entries in offset array
  size_t base_lg_;      // Encoding parameter (see kFilterBaseLg in .cc file)
};

}

#endif  // STORAGE_LEVELDB_TABLE_FILTER_BLOCK_H_