# require "jekyll"
# require_relative "../lib/jekyll_all_collections"

class Obj
  attr_reader :v1, :v2, :v3

  def initialize(param1, param2, param3)
    @v1 = param1
    @v2 = param2
    @v3 = param3
  end
end

RSpec.describe(Array) do
  let(:o1) { Obj.new(1, 1, 1) }
  let(:o2) { Obj.new(2, 1, 1) }
  let(:o3) { Obj.new(2, 2, 1) }
  let(:o4) { Obj.new(3, 2, 1) }
  let(:objs) { [o1, o2, o3, o4] }

  # See https://ruby-doc.org/3.2.0/Comparable.html
  it "uses comparators properly" do
    expect([o1.v1] <=> [o2.v1]).to eq(-1)
    expect([o1.v1, o1.v2] <=> [o2.v1, o2.v2]).to eq(-1)
    expect([o1.v2, o1.v1] <=> [o3.v1, o3.v2]).to eq(-1)
    expect([o1.v2, o1.v1] <=> [o3.v1, -o3.v2]).to eq(-1)
    expect([o2.v2, o1.v1] <=> [-o2.v2, o2.v1]).to eq(1)
    expect([o2.v2, o1.v1] <=> [-o2.v2, -o2.v1]).to eq(1)
  end

  # See https://ruby-doc.org/3.2.0/Enumerable.html#method-i-sort
  it "sorts by 2 keys, both ascending" do
    sort_lambda = ->(a, b) { [a.v1, a.v2] <=> [b.v1, b.v2] }
    result = objs.sort(&sort_lambda)
    expect(result).to eq([o1, o2, o3, o4])
  end

  it "sorts by 2 keys, both descending" do
    sort_lambda = ->(a, b) { [-a.v1, -a.v2] <=> [-b.v1, -b.v2] }
    result = objs.sort(&sort_lambda)
    expect(result).to eq([o4, o3, o2, o1])
  end

  it "sorts by 2 keys, first descending and second ascending" do
    sort_lambda = ->(a, b) { [-a.v1, a.v2] <=> [-b.v1, b.v2] }
    result = objs.sort(&sort_lambda)
    expect(result).to eq([o4, o2, o3, o1])
  end

  it "sorts by 2 keys, first ascending and second descending" do
    sort_lambda = ->(a, b) { [a.v1, -a.v2] <=> [b.v1, -b.v2] }
    result = objs.sort(&sort_lambda)
    expect(result).to eq([o1, o3, o2, o4])
  end
end
