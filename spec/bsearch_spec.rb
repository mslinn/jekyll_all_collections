require 'spec_helper'

RSpec.describe(Array) do
  sorted_ints = [0, 4, 7, 10, 12]
  sorted_strings = %w[aaa aab aac bbb bbc bbd ccc ccd cce]

  it 'returns index of first int match' do
    actual = sorted_ints.bsearch_index { |x| x >= 4 }
    expect(actual).to eq(1)

    actual = sorted_ints.bsearch_index { |x| x >= 6 }
    expect(actual).to eq(2)

    actual = sorted_ints.bsearch_index { |x| x >= -1 }
    expect(actual).to eq(0)

    actual = sorted_ints.bsearch_index { |x| x >= 100 }
    expect(actual).to be_nil
  end

  # start_with? gives crazy results, so use >=
  # See https://stackoverflow.com/q/79333097/553865
  it 'returns index of first string match' do
    actual = sorted_strings.bsearch_index { |x| x >= 'a' }
    expect(actual).to eq(0)

    actual = sorted_strings.bsearch_index { |x| x >= 'aa' }
    expect(actual).to eq(0)

    actual = sorted_strings.bsearch_index { |x| x >= 'aaa' }
    expect(actual).to eq(0)

    actual = sorted_strings.bsearch_index { |x| x >= 'b' }
    expect(actual).to eq(3)

    actual = sorted_strings.bsearch_index { |x| x >= 'bb' }
    expect(actual).to eq(3)

    actual = sorted_strings.bsearch_index { |x| x >= 'bbc' }
    expect(actual).to eq(4)

    actual = sorted_strings.bsearch_index { |x| x >= 'cce' }
    expect(actual).to eq(8)
  end
end
