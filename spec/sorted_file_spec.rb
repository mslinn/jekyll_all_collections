require 'spec_helper'
require_relative '../lib/hooks/all_files'

RSpec.describe(SortedLruFiles) do
  it 'can read back an inserted item' do
    sorted_files = described_class.new
    # expect(sorted_files.sorted_lru_files).to eq([])

    expected = 'testability.html'

    sorted_files.insert(expected, "https://mslinn.com/jekyll/10700-designing-for-#{expected}")
    # expect(sorted_files.sorted_lru_files.length).to eq(1)

    result = sorted_files.select expected
    expect(result).not_to be_empty
    result2 = result.first&.reversed_url&.reverse
    expect(result2&.end_with?(expected)).to be true

    result = sorted_files.select 'ability.html'
    result2 = result.first&.reversed_url&.reverse
    expect(result2&.end_with?('ability.html')).to be true

    result = sorted_files.select 'should_not_match'
    expect(result).to be_empty
  end
end
