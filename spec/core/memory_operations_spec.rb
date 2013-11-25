$LOAD_PATH << File.dirname(__FILE__) +'/../../src'
$LOAD_PATH << File.dirname(__FILE__) +'/../../generated'
require 'rspec'
require 'core/cpu'
require 'assembler/instruction_parser'
require 'assembler/expression_parser'

describe 'Correctly implements storing Operations' do
  before(:each) do
    @testing = CPU.new (Logger.new(File.open('/dev/null', 'a')))
    @instruction_parser = InstructionParser.new
    @instruction_parser.expression_evaluator = ExpressionParser.new(nil)

  end

  it 'should correctly move a word of memory' do
    start_address = 10
    destination_address = 100
    value = 42
    @testing.ri[0].store_long(destination_address)
    @testing.change_memory_word(0, @instruction_parser.as_word('MOVE %d' % start_address))
    @testing.change_memory_word(start_address, Word.new().store_long(value))
    @testing.change_memory_word(start_address + 1, Word.new().store_long(value))

    @testing.clock
    @testing.mu.memory[destination_address].long.should eq value
    @testing.mu.memory[destination_address + 1].long.should eq 0
    @testing.ri[0].long.should eq destination_address + 1
  end
  it 'should correctly move a block of memory' do
    start_address = 10
    destination_address = 100
    value = 42
    count = 50
    @testing.ri[0].store_long(destination_address)
    @testing.change_memory_word(0, @instruction_parser.as_word('MOVE %d(%d)' % [start_address, count]))
    count.times do |offset|
      @testing.change_memory_word(start_address + offset, Word.new().store_long(value + offset))
    end

    @testing.clock
    count.times do |offset|
      @testing.mu.memory[destination_address + offset].long.should eq value + offset
    end
    @testing.ri[0].long.should eq destination_address + count

  end
end