require 'spec_helper'
require_relative '../lib/util/mslinn_binary_search'

RSpec.describe(MSlinnBinarySearch) do
  sorted_strings = %w[aaa aab aac bbb bbc bbd ccc ccd cce]
  msbs = described_class.new [:url, %i[start_with? placeholder]]

  it 'returns index of first string match' do
    index = msbs.binary_search_index 'a' # { |x| x.start_with? 'a' }
    expect(sorted_strings[index]).to eq('aac')
  end
end
