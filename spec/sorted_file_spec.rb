require 'spec_helper'
require_relative '../lib/hooks/all_files'

RSpec.describe(SortedFiles) do
  it 'asdf' do
    sorted_files = described_class.new
    expect(sorted_files.sorted_lru_pages).to eq([])
  end
end
