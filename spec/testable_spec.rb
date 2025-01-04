require 'spec_helper'

module TestModule
  def a_method
    'a_method says Hi!'
  end
end

class TestClass
  extend TestModule # Defines class methods

  def initialize(param1, param2)
    super()
    @param1 = param1
    @param2 = param2
  end
end

RSpec.describe(TestModule) do # rubocop:disable RSpec/MultipleDescribes
  extend described_class

  it 'Invokes a_method from module' do
    result = self.class.a_method
    expect(result).to eq('a_method says Hi!')
  end
end

RSpec.describe(TestClass) do
  let(:o1) { described_class.new('value1', 'value2') }

  it 'Invokes a_method from class' do
    result = o1.class.a_method
    expect(result).to eq('a_method says Hi!')
  end
end
