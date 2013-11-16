require File.dirname(__FILE__) +'/../../src/autoload.rb'
require 'rspec'


describe 'Correctly implements string conversion operations' do
  before(:each) do
    @testing = CPU.new
    @instruction_parser = InstructionParser.new
    @address = 2500
    @register_word = Word.new([6, 7, 8, 9, 0])
    @testing.mu.memory[@address].load_value(Word.new(Sign::NEGATIVE, [1, 2, 3, 4, 5]))

  end

  it 'should correctly convert number to characters' do
    @testing.ra.store_long(1002045678)
    @testing.change_memory_word(@testing.ip, @instruction_parser.as_word('CHAR'))
    @testing.clock
    @testing.ra.string.should eq '10020'
    @testing.rx.string.should eq '45678'

  end

  it 'should correctly convert characters to number' do
    @testing.ra.store_string '10020'
    @testing.rx.store_string '45678'
    @testing.change_memory_word(@testing.ip, @instruction_parser.as_word('NUM'))
    @testing.clock

    @testing.ra.long.should eq 1002045678
    @testing.rx.string.should eq '45678'
    @testing.alu.overflow.should eq false
  end


  it 'should correctly convert characters to number with overflow' do
    @testing.ra.store_string '99999'
    @testing.rx.store_string '99999'
    @testing.change_memory_word(@testing.ip, @instruction_parser.as_word('NUM'))
    @testing.clock

    @testing.ra.long.should eq Limits::MAX_INT
    @testing.rx.string.should eq '99999'
    @testing.alu.overflow.should eq true
  end
end