require 'spec_helper'
require_relative '../lib/util/mslinn_binary_search'

sorted_strings = %w[aaa aab aac bbb bbc bbd ccc ccd cce]

def insert_from_sorted_strings
  string = sorted_strings.pop
  msbs.insert LruFile.new(string, "Page #{string}") # { |x| x.url.start_with? string }
end

RSpec.describe(MSlinnBinarySearch) do
  msbs = described_class.new [:url, %i[start_with? placeholder]]

  it 'handles empty msbs.array' do
    index = msbs.binary_search_index 'a' # { |x| x.url.start_with? 'a' }
    expect(index).to be_nil
  end

  it 'inserts an item into msbs.array' do
    insert_from_sorted_strings
    expect(msbs.array.length).to be(1)
  end

  it 'inserts remaining items into msbs.array' do
    insert_from_sorted_strings until sorted_strings.empty?
    expect(msbs.array.length).to be(9)
    expect(sorted_strings.length).to be_zero
  end

  it 'handles an empty search string by returning the index of the first item (0)' do
    index = msbs.binary_search_index '' # { |x| x.url.start_with? '' }
    expect(index).to be(0)

    lru_file = msbs.item_at(index)
    expect(lru_file.url).to be('aaa')
  end

  it 'returns the index of the first match' do
    index = msbs.find_index 'a' # { |x| x.url.start_with? 'a' }
    expect(index).to eq(0)

    index = msbs.find_index 'aab' # { |x| x.url.start_with? 'aab' }
    expect(index).to eq(1)

    index = msbs.find_index 'c' # { |x| x.url.start_with? 'c' }
    expect(index).to eq(6)

    index = msbs.find_index 'cce' # { |x| x.url.start_with? 'cce' }
    expect(index).to eq(8)
  end

  it 'returns the item of the first match' do
    item = msbs.find 'a' # { |x| x.url.start_with? 'a' }
    expect(item.url).to eq('aaa')

    item = msbs.find 'aab' # { |x| x.url.start_with? 'aab' }
    expect(item.url).to eq('aab')

    item = msbs.find 'c' # { |x| x.url.start_with? 'c' }
    expect(item.url).to eq('ccc')

    item = msbs.find 'cce' # { |x| x.url.start_with? 'cce' }
    expect(item.url).to eq('cce')
  end
end
