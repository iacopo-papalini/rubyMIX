$LOAD_PATH << File.dirname(__FILE__) +'/../../src'
$LOAD_PATH << File.dirname(__FILE__) +'/../../generated'
require 'rspec'
require 'core/cpu'
require 'assembler/instruction_parser'
require 'assembler/expression_parser'

describe 'Correctly implements loading Operations' do
  before(:each) do
    @testing = CPU.new (Logger.new(File.open('/dev/null', 'a')))
    @instruction_parser = InstructionParser.new
    @instruction_parser.expression_evaluator =  ExpressionParser.new(nil)
    @address = 2500
    @fix_num = -1234567
    @word = Word.new(Sign::NEGATIVE, [16, 1, 3, 5, 4])

  end

  it 'should correctly load a memory value in rA' do
    @testing.change_memory_word(@address, Word.new.store_long(@fix_num))
    @testing.change_memory_word(@testing.ip, @instruction_parser.as_word('LDA %d' % @address))
    @testing.clock

    @testing.ra.long.should eq @fix_num
  end

  it 'should correctly load an indexed memory value in rA ' do
    @testing.ri[0].store_long(100)
    @testing.change_memory_word(@address, Word.new.store_long(@fix_num))
    @testing.change_memory_word(@testing.ip, @instruction_parser.as_word('LDA 2400,1' ))
    @testing.clock

    @testing.ra.long.should eq @fix_num
  end

  it 'should correctly load a partial memory value in rA ans in page 129 (2)' do
    @testing.ri[0].store_long(100)
    @testing.change_memory_word(@address, @word)
    @testing.change_memory_word(@testing.ip, @instruction_parser.as_word('LDA %d(1:5)' % @address ))
    @testing.clock

    @testing.ra.should eq Word.new([16, 1, 3, 5, 4])
  end


  it 'should correctly load a partial memory value in rA ans in page 129 (3)' do
    @testing.ri[0].store_long(100)
    @testing.change_memory_word(@address, @word)
    @testing.change_memory_word(@testing.ip, @instruction_parser.as_word('LDA %d(3:5)' % @address ))
    @testing.clock

    @testing.ra.should eq Word.new([0, 0, 3, 5, 4])
  end

  it 'should correctly load a partial memory value in rA ans in page 129 (4)' do
    @testing.ri[0].store_long(100)
    @testing.change_memory_word(@address, @word)
    @testing.change_memory_word(@testing.ip, @instruction_parser.as_word('LDA %d(0:3)' % @address ))
    @testing.clock

    @testing.ra.should eq Word.new(Sign::NEGATIVE, [0, 0, 16, 1, 3])
  end


  it 'should correctly load a memory value in rX' do
    @testing.change_memory_word(@address, Word.new.store_long(@fix_num))
    @testing.change_memory_word(@testing.ip, @instruction_parser.as_word('LDX %d' % @address))
    @testing.clock

    @testing.rx.long.should eq @fix_num
  end

  it 'should correctly load a negated memory value in rX' do
    @testing.change_memory_word(@address, Word.new.store_long(@fix_num))
    @testing.change_memory_word(@testing.ip, @instruction_parser.as_word('LDXN %d' % @address))
    @testing.clock

    @testing.rx.long.should eq -@fix_num
  end
end