require 'spec_helper'

class Obj
  attr_reader :v1, :v2, :v3

  def initialize(param1, param2)
    @v1 = param1
    @v2 = param2
  end
end

RSpec.describe(Array) do # rubocop:disable Metrics/BlockLength
  let(:o1) { Obj.new(1, 1) }
  let(:o2) { Obj.new(2, 1) }
  let(:o3) { Obj.new(2, 2) }
  let(:o4) { Obj.new(3, 2) }
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
  it "sort with 2 keys, both ascending" do
    sort_lambda = ->(a, b) { [a.v1, a.v2] <=> [b.v1, b.v2] }
    result = objs.sort(&sort_lambda)
    expect(result).to eq([o1, o2, o3, o4])
  end

  it "sort_by with 2 keys, both ascending" do
    sort_lambda = ->(a) { [a.v1, a.v2] }
    result = objs.sort_by(&sort_lambda)
    expect(result).to eq([o1, o2, o3, o4])
  end

  it "sort with 2 keys, both descending" do
    sort_lambda = ->(a, b) { [-a.v1, -a.v2] <=> [-b.v1, -b.v2] }
    result = objs.sort(&sort_lambda)
    expect(result).to eq([o4, o3, o2, o1])
  end

  it "sort_by with 2 keys, both descending" do
    sort_lambda = ->(a) { [-a.v1, -a.v2] }
    result = objs.sort_by(&sort_lambda)
    expect(result).to eq([o4, o3, o2, o1])
  end

  it "sort with 2 keys, first descending and second ascending" do
    sort_lambda = ->(a, b) { [-a.v1, a.v2] <=> [-b.v1, b.v2] }
    result = objs.sort(&sort_lambda)
    expect(result).to eq([o4, o2, o3, o1])
  end

  it "sort_by with 2 keys, first descending and second ascending" do
    sort_lambda = ->(a) { [-a.v1, a.v2] }
    result = objs.sort_by(&sort_lambda)
    expect(result).to eq([o4, o2, o3, o1])
  end

  it "sort with 2 keys, first ascending and second descending" do
    sort_lambda = ->(a, b) { [a.v1, -a.v2] <=> [b.v1, -b.v2] }
    result = objs.sort(&sort_lambda)
    expect(result).to eq([o1, o3, o2, o4])
  end

  it "sort_by with 2 keys, first ascending and second descending" do
    sort_lambda = ->(a) { [a.v1, -a.v2] }
    result = objs.sort_by(&sort_lambda)
    expect(result).to eq([o1, o3, o2, o4])
  end
end

class APageStub
  attr_reader :date, :last_modified, :label

  def initialize(date, last_modified, label = '')
    @date = Date.parse date
    @last_modified = Date.parse last_modified
    @label = label
  end

  def to_s
    @label
  end
end

RSpec.describe(AllCollectionsTag) do
  let(:o1) { APageStub.new('2020-01-01', '2020-01-01', 'a_A') }
  let(:o2) { APageStub.new('2021-01-01', '2020-01-01', 'b_A') }
  let(:o3) { APageStub.new('2021-01-01', '2023-01-01', 'b_B') }
  let(:o4) { APageStub.new('2022-01-01', '2023-01-01', 'c_B') }
  let(:objs) { [o1, o2, o3, o4] }

  it "defines sort_by lambda with string" do
    sort_lambda = ->(a) { a.date }
    result = AllCollectionsTag::AllCollectionsTag.sort_me(objs, sort_lambda)
    expect(result).to eq([o1, o2, o3, o4])
  end

  it "makes sort_by lambdas with string" do
    sort_lambda = eval "->(a) { a.date }"
    result = AllCollectionsTag::AllCollectionsTag.sort_me(objs, sort_lambda)
    expect(result).to eq([o1, o2, o3, o4])
  end

  it "makes sort_by lambdas with array" do
    sort_lambda = eval "->(a) { [a.date] }"
    result = AllCollectionsTag::AllCollectionsTag.sort_me(objs, sort_lambda)
    expect(result).to eq([o1, o2, o3, o4])
  end

  it "create_lambda with 1 key, descending" do
    sort_lambda = AllCollectionsTag::AllCollectionsTag.create_lambda('-date')
    result = AllCollectionsTag::AllCollectionsTag.sort_me(objs, sort_lambda)
    expect(result).to eq([o4, o3, o2, o1])
  end

  it "create_lambda with 1 key, ascending" do
    sort_lambda = AllCollectionsTag::AllCollectionsTag.create_lambda('date')
    result = AllCollectionsTag::AllCollectionsTag.sort_me(objs, sort_lambda)
    expect(result).to eq([o1, o2, o3, o4])
  end

  it "create_lambda with 2 keys, both ascending" do
    sort_lambda = AllCollectionsTag::AllCollectionsTag.create_lambda(%w[date last_modified])
    result = AllCollectionsTag::AllCollectionsTag.sort_me(objs, sort_lambda)
    expect(result).to eq([o1, o2, o3, o4])
  end

  it "create_lambda with 2 keys, both descending" do
    sort_lambda = AllCollectionsTag::AllCollectionsTag.create_lambda(['-date', '-last_modified'])
    result = AllCollectionsTag::AllCollectionsTag.sort_me(objs, sort_lambda)
    expect(result).to eq([o4, o3, o2, o1])
  end

  it "create_lambda with 2 keys, first descending and second ascending" do
    sort_lambda = AllCollectionsTag::AllCollectionsTag.create_lambda(['-date', 'last_modified'])
    result = AllCollectionsTag::AllCollectionsTag.sort_me(objs, sort_lambda)
    expect(result).to eq([o4, o2, o3, o1])
  end

  it "create_lambda with 2 keys, first ascending and second descending" do
    sort_lambda = AllCollectionsTag::AllCollectionsTag.create_lambda(['date', '-last_modified'])
    result = AllCollectionsTag::AllCollectionsTag.sort_me(objs, sort_lambda)
    expect(result).to eq([o1, o3, o2, o4])
  end
end
