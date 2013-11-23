require File.dirname(__FILE__) +'/../../src/autoload.rb'
require 'rspec'


describe 'Correctly implements compare Operations' do
  before(:each) do
    @testing = CPU.new
    @instruction_parser = InstructionParser.new
    @instruction_parser.expression_evaluator = ExpressionParser.new(nil)
    @address = 2500
  end

  it 'should correctly compare register A with a value in memory (less)' do
    @testing.ra.store_long(-1)
    @testing.change_memory_word(@address, Word.new().store_long(1))
    @testing.change_memory_word(0, @instruction_parser.as_word('CMPA %d'%@address))

    @testing.clock
    @testing.alu.less.should eq true
  end
  it 'should correctly compare register R1 with a value in memory (equal)' do
    @testing.ri[0].store_long(1)
    @testing.change_memory_word(@address, Word.new().store_long(1))
    @testing.change_memory_word(0, @instruction_parser.as_word('CMP1 %d'%@address))

    @testing.clock
    @testing.alu.less.should eq false
    @testing.alu.greater.should eq false
    @testing.alu.equal.should eq true
  end
  it 'should correctly compare register X with a value in memory (partial, greater)' do
    @testing.rx.store_string("00B 0")
    @testing.change_memory_word(@address, Word.new().store_string("99A19"))
    @testing.change_memory_word(0, @instruction_parser.as_word('CMPX %d(3:4)'%@address))

    @testing.clock
    @testing.alu.less.should eq false
    @testing.alu.greater.should eq true
    @testing.alu.equal.should eq false
  end


end