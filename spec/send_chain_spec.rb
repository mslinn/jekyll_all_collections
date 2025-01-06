require 'spec_helper'
require_relative '../lib/util/send_chain'

LruFile = Struct.new(:url, :page) do
  include SendChain
end

RSpec.describe(LruFile) do
  lru_file = described_class.new 'abc', 'def'

  it 'performs simple call if no arguments are required' do
    # Equivalent to: LruFile.new("abc", "def").url.reverse
    actual = lru_file.send_chain %i[url reverse]
    expect(actual).to eq('cba')
  end

  it 'can provide arguments to a method' do
    lru_file.new_chain [:url, %i[end_with? placeholder]]

    # argument will be converted to an array if required
    actual = lru_file.send_chain_with_values 'bc'
    expect(actual).to be true

    actual = lru_file.send_chain_with_values ['bc']
    expect(actual).to be true
  end
end
