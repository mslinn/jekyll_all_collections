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

  it 'can accept a scalar argument in stages' do
    lru_file.new_chain [:url, %i[end_with? placeholder]]
    substituted_chain = lru_file.substitute_chain 'bc'
    actual = lru_file.send_substituted_chain substituted_chain
    expect(actual).to be true
  end

  it 'can accept a vector argument in stages' do
    lru_file.new_chain [:url, %i[end_with? placeholder]]
    substituted_chain = lru_file.substitute_chain ['bc']
    actual = lru_file.send_substituted_chain substituted_chain
    expect(actual).to be true
  end

  it 'can accept a scalar argument in one stage' do
    lru_file.new_chain [:url, %i[end_with? placeholder]]
    actual = lru_file.substitute_and_send_chain_with 'bc'
    expect(actual).to be true
  end

  it 'can accept an array argument in one stage' do
    lru_file.new_chain [:url, %i[end_with? placeholder]]
    actual = lru_file.substitute_and_send_chain_with ['bc']
    expect(actual).to be true
  end

  it 'can reuse the chain with different values' do
    lru_file.new_chain [:url, %i[end_with? placeholder]]

    actual = lru_file.substitute_and_send_chain_with 'bc'
    expect(actual).to be true

    substituted_chain = lru_file.substitute_chain ['abc']
    actual = lru_file.send_substituted_chain substituted_chain
    expect(actual).to be true

    actual = lru_file.substitute_and_send_chain_with 'de'
    expect(actual).to be false
  end
end
