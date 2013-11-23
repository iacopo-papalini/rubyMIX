require File.dirname(__FILE__) +'/../../src/autoload.rb'
require 'rspec'

describe 'Correctly implements Address @t.ansfer Operations' do
  before(:each) do
    @testing = CPU.new
    @instruction_parser = InstructionParser.new
    @instruction_parser.expression_evaluator =  ExpressionParser.new(nil)
  end


  it 'change r? value on load instruction' do
    @testing.ra.long.should eq 0
    @testing.change_memory_word(0, Word.new([1, 1, 0, 2, 48])) # ENTA      65
    @testing.clock
    @testing.ra.long.should eq 65

    @testing.rx.long.should eq 0
    @testing.change_memory_word(1, Word.new([1, 1, 0, 2, 55])) # ENTX      65
    @testing.clock
    @testing.rx.long.should eq 65

    @testing.ri[3].long.should eq 0
    @testing.change_memory_word(2, Word.new([1, 1, 0, 2, 52])) # ENT4      65
    @testing.clock
    @testing.ri[3].long.should eq 65
  end

  it 'change the memory location with a negative value' do
    @testing.change_memory_word(0,  Word.new(Sign::NEGATIVE, [0, 1, 0, 2, 48])) # @instruction_parser.as_word('ENT1    -1'))
    @testing.clock
    @testing.ra.long.should eq -1
  end

  it 'change rA value on load instruction with index register add' do
    @testing.ri[5].store_long(-1)
    @testing.change_memory_word(0, Word.new([1, 1, 6, 2, 48])) # ENTA      65,6
    @testing.clock
    @testing.ra.long.should eq 64

  end
  it 'change ri5 value on load negate instruction' do
    @testing.change_memory_word(0, Word.new([1, 1, 0, 3, 53])) # ENN5      65

    @testing.clock
    @testing.ri[4].long.should eq -65
    @testing.change_memory_word(1, Word.new(Sign::NEGATIVE, [1, 1, 0, 3, 53])) # ENN5      -65

    @testing.clock
    @testing.ri[4].long.should eq 65
  end
  it 'change rA value on increment instruction' do
    @testing.change_memory_word(0, Word.new([1, 1, 0, 0, 48])) # INCA      65
    @testing.ra.store_long(35)

    @testing.clock
    @testing.ra.long.should eq 100
    @testing.change_memory_word(1, Word.new(Sign::NEGATIVE, [1, 1, 0, 0, 48])) # INCA      -65
    @testing.ra.store_long(35)

    @testing.clock
    @testing.ra.long.should eq -30
  end

  it 'change rX value on decrement instruction' do
    @testing.change_memory_word(0, Word.new([1, 1, 0, 1, 55])) # DECX      65
    @testing.rx.store_long(35)

    @testing.clock
    @testing.rx.long.should eq -30
    @testing.change_memory_word(1, Word.new(Sign::NEGATIVE, [1, 1, 0, 1, 55])) # DECX      -65
    @testing.rx.store_long(35)

    @testing.clock
    @testing.rx.long.should eq 100
  end
end