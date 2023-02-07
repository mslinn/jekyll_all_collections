require "jekyll"
require_relative "../lib/jekyll_all_collections"

class Obj
  attr_reader :v1, :v2, :v3

  def initialize(param1, param2, param3)
    @v1 = param1
    @v2 = param2
    @v3 = param3
  end
end

# See https://stackoverflow.com/a/16628808/553865
RSpec.describe(JekyllAllCollections) do
  let(:o1) { Obj.new(1, 1, 1) }
  let(:o2) { Obj.new(2, 1, 1) }
  let(:o3) { Obj.new(2, 2, 1) }
  let(:o4) { Obj.new(3, 2, 1) }
  let(:objs) { [o1, o2, o3, o4] }

  it "sorts by 2 keys, both ascending" do
    result = (objs.sort { |a, b| [a.v1, a.v2] <=> [b.v1, b.v2] })
    expect(result).to eq([o1, o2, o3, o4])
  end

  it "sorts by 2 keys, first descending and second ascending" do
    result = (objs.sort { |a, b| [b.v1, a.v2] <=> [a.v1, b.v2] })
    expect(result).to eq([o4, o2, o3, o1])
  end

  it "sorts by 2 keys, first ascending and second descending" do
    result = (objs.sort { |a, b| [a.v1, b.v2] <=> [b.v1, a.v2] })
    expect(result).to eq([o1, o3, o2, o4])
  end
end
