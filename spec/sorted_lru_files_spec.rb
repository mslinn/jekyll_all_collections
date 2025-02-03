require 'spec_helper'
require_relative '../lib/hooks/all_files'

RSpec.describe(SortedLruFiles) do
  sorted_files = described_class.new
  expected1 = 'first-page.html'
  expected2 = 'second-page.html'
  expected3 = 'third-page.html'

  it 'can read back an inserted item' do
    sorted_files.insert(expected1, "https://mslinn.com/#{expected1}")

    actual = sorted_files.select expected1
    expect(actual.length).to eq(1)
    expect(actual.first&.url&.end_with?(expected1)).to be true

    actual = sorted_files.select expected1[5..]
    expect(actual.length).to eq(1)
    expect(actual.first&.url&.end_with?(expected1[5..])).to be true

    actual = sorted_files.select 'should_not_match'
    expect(actual).to be_empty
  end

  it 'works with 2 items' do
    sorted_files.insert(expected2, "https://mslinn.com/#{expected2}")
    expect(sorted_files.msbs.array[0].url).to be <= sorted_files.msbs.array[1].url

    actual = sorted_files.select expected1
    expect(actual.length).to eq(1)
    expect(actual.first&.url&.end_with?(expected1)).to be true

    actual = sorted_files.select expected2
    expect(actual.length).to eq(1)
    expect(actual.first&.url&.end_with?(expected2)).to be true

    expected = '.html'
    actual = sorted_files.select expected
    expect(actual.length).to eq(2)
    expect(actual.first&.url&.end_with?(expected)).to be true
  end

  it 'works with 3 items' do
    sorted_files.insert(expected2, "https://mslinn.com/#{expected}")

    expect(sorted_files.msbs.array[0].url).to be_lte(sorted_files.msbs.array[1].url)
    expect(sorted_files.msbs.array[1].url).to be_lte(sorted_files.msbs.array[2].url)

    actual = sorted_files.select expected1
    expect(actual.length).to eq(1)
    expect(actual.first&.url&.end_with?(expected1)).to be true

    actual = sorted_files.select expected2
    expect(actual.length).to eq(1)
    expect(actual.first&.url&.end_with?(expected2)).to be true

    actual = sorted_files.select expected3
    expect(actual.length).to eq(2)
    expect(actual.first&.url&.end_with?(expected3)).to be true

    expected = '.html'
    actual = sorted_files.select expected
    expect(actual.length).to eq(3)
    expect(actual.first&.url&.end_with?(expected)).to be true
  end
end
