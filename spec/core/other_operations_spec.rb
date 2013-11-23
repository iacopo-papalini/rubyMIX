require File.dirname(__FILE__) +'/../../src/autoload.rb'
require 'rspec'


describe 'Correctly implements various Operations' do
  before(:each) do
    @testing = CPU.new
    @instruction_parser = InstructionParser.new
    @instruction_parser.expression_evaluator =  ExpressionParser.new(nil)
    @address = 2500
    @register_word = Word.new([6, 7, 8, 9, 0])
    @testing.mu.memory[@address].load_value(Word.new(Sign::NEGATIVE, [1, 2, 3, 4, 5]))

  end

  it 'should correctly halt' do
    @testing.change_memory_word(@testing.ip, @instruction_parser.as_word('HLT'))

    @testing.clock

    @testing.halt.should eq true
    @testing.ip.should eq nil
  end

  it 'should do nothing on IOC' do
    @testing.change_memory_word(@testing.ip, @instruction_parser.as_word('IOC 0(18)'))

    @testing.clock

  end
  it 'should raise exception for unimplemented operation' do
    @testing.mu.memory[0].bytes[4] = 65
    expect {
      @testing.clock }.to raise_error
  end
end