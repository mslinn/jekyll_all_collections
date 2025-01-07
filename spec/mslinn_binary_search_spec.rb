require 'spec_helper'
require_relative '../lib/hooks/all_files'

RSpec.describe(MSlinnBinarySearch) do
  $msbs = described_class.new [:url, %i[start_with? placeholder]]
  $sorted_strings = %w[aaa aab aac bbb bbc bbd ccc ccd cce]

  def insert_from_sorted_strings
    string = $sorted_strings.shift
    $msbs.insert LruFile.new(string, "Page #{string}") # { |x| x.url.start_with? string }
  end

  it 'handles empty $msbs.array' do
    index = $msbs.find_index 'a' # { |x| x.url.start_with? 'a' }
    expect(index).to be_nil
  end

  it 'inserts an item into $msbs.array' do
    insert_from_sorted_strings
    expect($msbs.array.length).to be(1)
  end

  it 'inserts remaining items into $msbs.array in order' do
    until $sorted_strings.empty?
      insert_from_sorted_strings
      (0..($msbs.array.length - 2)).each do |i|
        if $msbs.array[i].url > $msbs.array[i + 1].url
          failure_msg = "Oops: array[#{i}].url (#{$msbs.array[i].url}) > array[#{i + 1}].url (#{$msbs.array[i + 1].url})"
          RSpec::Expectations.fail_with failure_msg
        end
      end
    end
    expect($msbs.array.length).to be(9)
    expect($sorted_strings.length).to be_zero
  end

  it 'handles an empty search string by returning the index of the first item (0)' do
    index = $msbs.find_index '' # { |x| x.url.start_with? '' }
    expect(index).to be(0)
  end

  it 'returns the item with a full match' do
    lru_file = $msbs.item_at(0)
    expect(lru_file.url).to eq('aaa')

    lru_file = $msbs.item_at(1)
    expect(lru_file.url).to eq('aab')

    lru_file = $msbs.item_at(8)
    expect(lru_file.url).to eq('cce')
  end

  it 'returns the index of the first partial match' do
    index = $msbs.find_index 'a' # { |x| x.url.start_with? 'a' }
    expect(index).to eq(0)

    index = $msbs.find_index 'aab' # { |x| x.url.start_with? 'aab' }
    expect(index).to eq(1)

    index = $msbs.find_index 'c' # { |x| x.url.start_with? 'c' }
    expect(index).to eq(6)

    index = $msbs.find_index 'cce' # { |x| x.url.start_with? 'cce' }
    expect(index).to eq(8)
  end

  it 'returns the item of the first match' do
    item = $msbs.find 'a' # { |x| x.url.start_with? 'a' }
    expect(item.url).to eq('aaa')

    item = $msbs.find 'aab' # { |x| x.url.start_with? 'aab' }
    expect(item.url).to eq('aab')

    item = $msbs.find 'c' # { |x| x.url.start_with? 'c' }
    expect(item.url).to eq('ccc')

    item = $msbs.find 'cce' # { |x| x.url.start_with? 'cce' }
    expect(item.url).to eq('cce')
  end
end
