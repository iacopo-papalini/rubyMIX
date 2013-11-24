$LOAD_PATH << File.dirname(__FILE__) +'/../../src'
$LOAD_PATH << File.dirname(__FILE__) +'/../../generated'
require 'rspec'
require 'core/cpu'
require 'assembler/instruction_parser'
require 'assembler/expression_parser'

def verify_long_division(a, divisor, x)
  very_long =  (a << (Limits::BITS_IN_BYTE*Limits::BYTES_IN_WORD) ) + x
  dw = DoubleWord.new.store_long(very_long)
  division = dw.long / divisor
  remainder = dw.sign * (dw.long.abs % divisor)
  @testing.ra.load_value(Word.new(dw.bytes[0..4]))
  @testing.ra.sign = dw.sign

  @testing.rx.load_value(Word.new(dw.bytes[5..9]))
  @testing.change_memory_word(@address, Word.new().store_long(divisor))
  @testing.change_memory_word(@testing.ip, @instruction_parser.as_word('DIV %d' % @address))

  @testing.clock

  @testing.ra.long.should eq division
  @testing.rx.long.should eq remainder
end

describe 'Correctly implements arithmetic Operations' do
  before(:each) do
    @testing = CPU.new (Logger.new(File.open('/dev/null', 'a')))
    @instruction_parser = InstructionParser.new
    @instruction_parser.expression_evaluator =  ExpressionParser.new(nil)
    @address = 2500
    @fix_num = -65 # [0,0,0,1,1]
    @register_value = 18000000
    @testing.change_memory_word(@address, Word.new.store_long(@fix_num))
    @testing.ra.store_long(@register_value)


  end

  it 'should add the value of the memory cell to rA' do
    @testing.change_memory_word(@testing.ip, @instruction_parser.as_word('ADD %d' % @address))

    @testing.clock

    @testing.ra.long.should eq @register_value+@fix_num
  end
  it 'should add the partial value of the memory cell to rA' do
    @testing.change_memory_word(@testing.ip, @instruction_parser.as_word('ADD %d(5:5)' % @address))

    @testing.clock

    @testing.ra.long.should eq @register_value+1
  end

  it 'should handle the overflow' do
    @testing.change_memory_word(@address, Word.new.store_long(Limits::MAX_INT - 1))
    @testing.change_memory_word(@testing.ip, @instruction_parser.as_word('ADD %d' % @address))

    @testing.clock

    @testing.ra.long.should eq @register_value - 1
    @testing.alu.overflow.should eq true
  end

  it 'should handle the underflow' do
    @testing.ra.store_long(-@register_value)
    @testing.change_memory_word(@address, Word.new.store_long(-Limits::MAX_INT + 1))
    @testing.change_memory_word(@testing.ip, @instruction_parser.as_word('ADD %d' % @address))
    @testing.alu.overflow.should eq false
    @testing.clock

    @testing.ra.long.should eq (-@register_value + 1)
    @testing.alu.overflow.should eq true
  end

  it 'should subtract the value of the memory cell to rA' do
    @testing.change_memory_word(@testing.ip, @instruction_parser.as_word('SUB %d' % @address))

    @testing.clock

    @testing.ra.long.should eq @register_value - @fix_num
  end


  it 'should multiply the value of the memory cell times rA, as in first example of The Art of Computer Programming v.1 pag 132' do
    @testing.ra.load_value(Word.new([1, 1, 1, 1, 1]))
    @testing.change_memory_word(@address, Word.new([1, 1, 1, 1, 1]))
    @testing.change_memory_word(@testing.ip, @instruction_parser.as_word('MUL %d' % @address))

    @testing.clock

    @testing.ra.bytes.should eq [0, 1, 2, 3, 4]
    @testing.rx.bytes.should eq [5, 4, 3, 2, 1]
  end

  it 'should multiply the value of the memory cell times rA, as in second example of The Art of Computer Programming v.1 pag 132' do
    @testing.ra.store_long(-112)
    @testing.change_memory_word(@address, Word.new([2, 3, 4, 5, 6]))
    @testing.change_memory_word(@testing.ip, @instruction_parser.as_word('MUL %d(1:1)' % @address))

    @testing.clock

    @testing.ra.long.should eq 0
    @testing.ra.sign.should eq Sign::NEGATIVE
    @testing.rx.long.should eq -224
  end

  it 'should multiply the value of the memory cell times rA, as in third example of The Art of Computer Programming v.1 pag 132' do
    @testing.ra.load_value( Word.new(Sign::NEGATIVE,[50, 0, 1, 48, 4]))
    @testing.change_memory_word(@address, Word.new(Sign::NEGATIVE, [2, 0, 0, 0, 0]))
    @testing.change_memory_word(@testing.ip, @instruction_parser.as_word('MUL %d' % @address))

    @testing.clock

    @testing.ra.bytes.should eq [1, 36, 0, 3, 32]
    @testing.ra.sign.should eq Sign::POSITIVE
    @testing.rx.bytes.should eq [8,0,0,0,0]
    @testing.rx.sign.should eq Sign::POSITIVE
  end

  it 'should perform a simple division as in the sixth example of The Art of Computer Programming v.1 pag 132' do
    @testing.ra.load_value( Word.new().store_long(0))
    @testing.rx.load_value( Word.new().store_long(17))
    @testing.change_memory_word(@address, Word.new().store_long(3))
    @testing.change_memory_word(@testing.ip, @instruction_parser.as_word('DIV %d' % @address))

    @testing.clock

    @testing.ra.long.should eq 5
    @testing.rx.long.should eq 2
  end

  it 'should perform long division' do
    a = 1
    x = 10
    divisor = 7
    verify_long_division(a, divisor, x)
  end
  it 'should perform long division with negative divisor' do
    a = -3
    x = -1
    divisor = 7
    verify_long_division(a, divisor, x)
    @testing.ra.sign.should eq Sign::NEGATIVE
    @testing.rx.sign.should eq Sign::NEGATIVE
  end
end