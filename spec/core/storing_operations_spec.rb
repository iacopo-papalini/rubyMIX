require File.dirname(__FILE__) +'/../../src/autoload.rb'
require 'rspec'

describe 'Correctly implements storing Operations' do
  before(:each) do
    @testing = CPU.new
    @instruction_parser = InstructionParser.new
    @instruction_parser.expression_evaluator = ExpressionParser.new(nil)
    @address = 2500
    @register_word = Word.new([6, 7, 8, 9, 0])
    @testing.mu.memory[@address].load_value(Word.new(Sign::NEGATIVE, [1, 2, 3, 4, 5]))

  end

  it 'should correctly store the value in rA' do
    @testing.ra.load_value(@register_word)
    @testing.change_memory_word(@testing.ip, @instruction_parser.as_word('STA %d' % @address))

    @testing.clock
    @testing.mu.memory[@address].should eq @register_word
  end

  it 'should raise exception for invalid memory address' do
    @testing.ra.load_value(@register_word)
    @testing.change_memory_word(@testing.ip, @instruction_parser.as_word('STA -%d' % @address))

    expect {
      @testing.clock }.to raise_error
  end

  it 'should correctly store the partial value in rA' do
    @testing.ra.load_value(@register_word)
    @testing.change_memory_word(@testing.ip, @instruction_parser.as_word('STA %d(2:3)' % @address))

    @testing.clock
    @testing.mu.memory[@address].should eq Word.new(Sign::NEGATIVE, [1, 9, 0, 4, 5])
  end

  it 'should correctly store the indexed and partial value in rA' do
    shift = 200
    @testing.ra.load_value(@register_word)
    @testing.ri[2].store_long(shift)
    @testing.change_memory_word(@testing.ip, @instruction_parser.as_word('STA %d,3(2:3)' % (@address - shift)))

    @testing.clock
    @testing.mu.memory[@address].should eq Word.new(Sign::NEGATIVE, [1, 9, 0, 4, 5])
  end


  it 'should correctly store the value in rX' do
    @testing.rx.load_value(@register_word)
    @testing.change_memory_word(@testing.ip, @instruction_parser.as_word('STX %d' % @address))

    @testing.clock
    @testing.mu.memory[@address].should eq @register_word
  end

  it 'should correctly store the value in ri6' do
    @testing.ri[5].load_value(@register_word)
    @testing.change_memory_word(@testing.ip, @instruction_parser.as_word('ST6 %d' % @address))

    @testing.clock
    @testing.mu.memory[@address].should eq @register_word
  end

  it 'should correctly store the value in rJ' do
    @testing.rj.store_value(@register_word)
    @testing.change_memory_word(@testing.ip, @instruction_parser.as_word('STJ %d' % @address))

    @testing.clock
    @testing.mu.memory[@address].should eq Word.new([9, 0, 3, 4, 5])
  end

  it 'should store the value in rJ ignoring sign' do
    @testing.rj.store_value(@register_word)
    @testing.change_memory_word(@testing.ip, @instruction_parser.as_word('STJ %d(1:2)' % @address))

    @testing.clock
    @testing.mu.memory[@address].should eq Word.new(Sign::NEGATIVE, [9, 0, 3, 4, 5])
  end

  it 'should clear a memory location with STZ' do
    @testing.change_memory_word(@testing.ip, @instruction_parser.as_word('STZ %d' % @address))
    @testing.clock
    @testing.mu.memory[@address].should eq Word.new([0, 0, 0, 0, 0])
  end

  it 'should partially clear a memory location with STZ - 1' do
    @testing.change_memory_word(@testing.ip, @instruction_parser.as_word('STZ %d(4:5)' % @address))
    @testing.clock
    @testing.mu.memory[@address].should eq Word.new(Sign::NEGATIVE, [1, 2, 3, 0, 0])
  end

  it 'should partially clear a memory location with STZ - 2' do
    @testing.change_memory_word(@testing.ip, @instruction_parser.as_word('STZ %d(0:3)' % @address))
    @testing.clock
    @testing.mu.memory[@address].should eq Word.new(Sign::POSITIVE, [0, 0, 0, 4, 5])
  end

  it 'should correctly store short register' do
    @testing.ri[1].store_long(-65)
    @testing.change_memory_word(@testing.ip, @instruction_parser.as_word('ST2 %d' % @address))
    @testing.clock

    @testing.mu.memory[@address].to_s.should eq Word.new(Sign::NEGATIVE, [0,0,0,1,1]).to_s

  end
end