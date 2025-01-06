require 'spec_helper'
require_relative '../lib/hooks/all_files'

RSpec.describe(SortedLruFiles) do
  it 'can read back an inserted item' do
    sorted_files = described_class.new
    expected = 'testability.html'
    sorted_files.insert(expected, "https://mslinn.com/jekyll/10700-designing-for-#{expected}")

    result = sorted_files.select_mormalized expected
    expect(result.length).to eq(1)
    expect(result.first&.reversed_url&.end_with?(expected)).to be true

    result = sorted_files.select_mormalized expected[5..]
    expect(result.length).to eq(1)
    expect(result.first&.reversed_url&.end_with?(expected[5..])).to be true

    result = sorted_files.select_mormalized 'should_not_match'
    expect(result).to be_empty
  end
end
