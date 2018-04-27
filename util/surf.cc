#include "pebblesdb/filter_policy.h"
#include "pebblesdb/slice.h"
// #include "table/block_based_filter_block.h"
// #include "table/full_filter_bits_builder.h"
// #include "table/full_filter_block.h"

#include "third-party/SuRF/include/surf.hpp"


#include <iostream>

namespace leveldb {

// class BlockBasedFilterBlockBuilder;
// class FullFilterBlockBuilder;

class FullSuRFBitsBuilder : public FilterBitsBuilder {
public:
    explicit FullSuRFBitsBuilder(int suffix_type, uint32_t hash_suffix_len, uint32_t real_suffix_len,
				 bool include_dense, uint32_t sparse_dense_ratio)
	: hash_suffix_len_(hash_suffix_len), real_suffix_len_(real_suffix_len), include_dense_(include_dense),
	  sparse_dense_ratio_(sparse_dense_ratio) {
	if (suffix_type == 1)
	    suffix_type_ = surf::kHash;
	else if (suffix_type == 2)
	    suffix_type_ = surf::kReal;
	else
	    suffix_type_ = surf::kNone;
    }

    ~FullSuRFBitsBuilder() {}

    virtual void AddKey(const Slice& key) override {
	keys_.push_back(std::string(key.data(), key.size()));
    }

    virtual Slice Finish(std::unique_ptr<const char[]>* buf) override {
	surf::SuRF* filter = new surf::SuRF(keys_, include_dense_, sparse_dense_ratio_,
					    suffix_type_, hash_suffix_len_, real_suffix_len_);
	uint64_t size = filter->serializedSize();
	char* data = filter->serialize();
	filter->destroy();
	delete filter;
	buf->reset(data);
	return Slice(data, size);
    }

    virtual int CalculateNumEntry(const uint32_t space) override {
	return (int)keys_.size();
    }

private:
    surf::SuffixType suffix_type_;
    surf::level_t hash_suffix_len_;
	surf::level_t real_suffix_len_;
    bool include_dense_;
    uint32_t sparse_dense_ratio_;

    std::vector<std::string> keys_;
};

class FullSuRFBitsReader : public FilterBitsReader {
public:
    explicit FullSuRFBitsReader(const Slice& contents)
	: data_(const_cast<char*>(contents.data())),
	  size_(static_cast<uint64_t>(contents.size())) {
	char* data = data_;
	filter_ = surf::SuRF::deSerialize(data);
    }

    ~FullSuRFBitsReader() {
	delete filter_;
    }

    virtual bool MayMatch(const Slice& entry) override {
	return filter_->lookupKey(std::string(entry.data(), entry.size()));
    }

    // huanchen
    virtual Slice Seek(const Slice& entry, unsigned* bitlen, const bool inclusive) override {
	surf::SuRF::Iter iter = filter_->moveToKeyGreaterThan(std::string(entry.data(), entry.size()), inclusive);
	return Slice(iter.getKeyWithSuffix(bitlen));
    }

    // huanchen
    virtual Slice SeekForPrev(const Slice& entry, unsigned* bitlen, const bool inclusive) override {
	surf::SuRF::Iter iter = filter_->moveToKeyLessThan(std::string(entry.data(), entry.size()), inclusive);
	return Slice(iter.getKeyWithSuffix(bitlen));
    }

private:
    char* data_;
    uint64_t size_;
    surf::SuRF* filter_;
};

class SuRFPolicy : public FilterPolicy {
public:
    explicit SuRFPolicy(int suffix_type, uint32_t hash_suffix_len, uint32_t real_suffix_len,
			bool include_dense, uint32_t sparse_dense_ratio,
			bool use_block_based_builder)
	: hash_suffix_len_(hash_suffix_len), real_suffix_len_(real_suffix_len), include_dense_(include_dense),
	  sparse_dense_ratio_(sparse_dense_ratio),
	  use_block_based_builder_(use_block_based_builder) {
	if (suffix_type == 1)
	    suffix_type_ = surf::kHash;
	else if (suffix_type == 2)
	    suffix_type_ = surf::kReal;
	else
	    suffix_type_ = surf::kNone;
    }

    ~SuRFPolicy() {
    }

    virtual const char* Name() const override {
	return "rocksdb.SuRFFilter";
    }

    virtual void CreateFilter(const Slice* keys, int n,
			      std::string* dst) const override {
	std::vector<std::string> keys_str;
	for (size_t i = 0; i < (size_t)n; i++)
	    keys_str.push_back(std::string(keys[i].data(), keys[i].size()));
	
	surf::SuRF* filter = new surf::SuRF(keys_str, include_dense_, sparse_dense_ratio_,
					    suffix_type_, hash_suffix_len_, real_suffix_len_);
	uint64_t size = filter->serializedSize();
	char* data = filter->serialize();
	dst->append(data, size);
	filter->destroy();
	delete filter;
    }

    virtual bool KeyMayMatch(const Slice& key,
			     const Slice& filter) const override {
	char* filter_data = const_cast<char*>(filter.data());
	char* data = filter_data;
	surf::SuRF* filter_surf = surf::SuRF::deSerialize(data);
	bool found = filter_surf->lookupKey(std::string(key.data(), key.size()));
	delete filter_surf;
	return found;
    }

    virtual FilterBitsBuilder* GetFilterBitsBuilder() const override {
	if (use_block_based_builder_) {
	    return nullptr;
	}
	return new FullSuRFBitsBuilder(suffix_type_, hash_suffix_len_, real_suffix_len_, include_dense_,
				       sparse_dense_ratio_);
    }

    virtual FilterBitsReader* GetFilterBitsReader(const Slice& contents) const override {
	return new FullSuRFBitsReader(contents);
    }

    // If choose to use block based builder
    bool UseBlockBasedBuilder() { return use_block_based_builder_; }

private:
    surf::SuffixType suffix_type_;
    surf::level_t hash_suffix_len_;
	surf::level_t real_suffix_len_;
    bool include_dense_;
    uint32_t sparse_dense_ratio_;

    const bool use_block_based_builder_;
};

const FilterPolicy* NewSuRFPolicy(int suffix_type,
				  uint32_t hash_suffix_len,
				  uint32_t real_suffix_len,
				  bool include_dense,
				  uint32_t sparse_dense_ratio,
				  bool use_block_based_builder) {
    return new SuRFPolicy(suffix_type, hash_suffix_len, real_suffix_len, include_dense,
			  sparse_dense_ratio, use_block_based_builder);
}

} // namespace rocksdb