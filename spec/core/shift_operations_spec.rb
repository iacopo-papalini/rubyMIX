$LOAD_PATH << File.dirname(__FILE__) +'/../../src'
$LOAD_PATH << File.dirname(__FILE__) +'/../../generated'
require 'rspec'
require 'core/cpu'
require 'assembler/instruction_parser'
require 'assembler/expression_parser'

describe 'Correctly implements Shift Operations' do
  before(:each) do
    @testing = CPU.new (Logger.new(File.open('/dev/null', 'a')))
    @instruction_parser = InstructionParser.new
    @instruction_parser.expression_evaluator = ExpressionParser.new(nil)
  end

  it 'Should correctly shift left A one' do
    @testing.ra.load_value(Word.new([1, 2, 3, 4, 5]))
    @testing.change_memory_word(0, @instruction_parser.as_word('SLA 1'))

    @testing.clock

    @testing.ra.bytes.should eq (Word.new([2, 3, 4, 5, 0]).bytes)
  end
  it 'Should correctly shift left A three' do
    @testing.ra.load_value(Word.new([1, 2, 3, 4, 5]))
    @testing.change_memory_word(0, @instruction_parser.as_word('SLA 3'))

    @testing.clock

    @testing.ra.bytes.should eq (Word.new([4, 5, 0, 0, 0]).bytes)
  end
  it 'Should correctly shift left A six - zeroing buffer' do
    @testing.ra.load_value(Word.new([1, 2, 3, 4, 5]))
    @testing.change_memory_word(0, @instruction_parser.as_word('SLA 6'))

    @testing.clock

    @testing.ra.bytes.should eq (Word.new([0, 0, 0, 0, 0]).bytes)
  end

  it 'Should correctly shift right A one' do
    @testing.ra.load_value(Word.new([1, 2, 3, 4, 5]))
    @testing.change_memory_word(0, @instruction_parser.as_word('SRA 1'))

    @testing.clock

    @testing.ra.bytes.should eq (Word.new([0, 1, 2, 3, 4]).bytes)
  end

  it 'Should correctly shift right A three' do
    @testing.ra.load_value(Word.new([1, 2, 3, 4, 5]))
    @testing.change_memory_word(0, @instruction_parser.as_word('SRA 3'))

    @testing.clock

    @testing.ra.bytes.should eq (Word.new([0, 0, 0, 1, 2]).bytes)
  end
  it 'Should correctly shift left A and X one' do
    @testing.ra.load_value(Word.new([1, 2, 3, 4, 5]))
    @testing.rx.load_value(Word.new(Sign::NEGATIVE, [6, 7, 8, 9, 10]))
    @testing.change_memory_word(0, @instruction_parser.as_word('SLAX 1'))

    @testing.clock

    @testing.ra.bytes.should eq (Word.new([2, 3, 4, 5, 6]).bytes)
    @testing.rx.bytes.should eq (Word.new([7, 8, 9, 10, 0]).bytes)
    @testing.rx.sign.should eq Sign::NEGATIVE
  end
  it 'Should correctly shift left A and X seven' do
    @testing.ra.load_value(Word.new([1, 2, 3, 4, 5]))
    @testing.rx.load_value(Word.new(Sign::NEGATIVE, [6, 7, 8, 9, 10]))
    @testing.change_memory_word(0, @instruction_parser.as_word('SLAX 7'))

    @testing.clock

    @testing.ra.bytes.should eq (Word.new([8, 9, 10, 0, 0]).bytes)
    @testing.rx.bytes.should eq (Word.new([0, 0, 0, 0, 0]).bytes)
    @testing.rx.sign.should eq Sign::NEGATIVE
  end
  it 'Should correctly shift right A and X two' do
    @testing.ra.load_value(Word.new([1, 2, 3, 4, 5]))
    @testing.rx.load_value(Word.new(Sign::NEGATIVE, [6, 7, 8, 9, 10]))
    @testing.change_memory_word(0, @instruction_parser.as_word('SRAX 2'))

    @testing.clock

    @testing.ra.bytes.should eq (Word.new([0, 0, 1, 2, 3]).bytes)
    @testing.rx.bytes.should eq (Word.new([4, 5, 6, 7, 8]).bytes)
    @testing.rx.sign.should eq Sign::NEGATIVE
  end

  it 'Should correctly shift right A and X nine' do
    @testing.ra.load_value(Word.new([1, 2, 3, 4, 5]))
    @testing.rx.load_value(Word.new(Sign::NEGATIVE, [6, 7, 8, 9, 10]))
    @testing.change_memory_word(0, @instruction_parser.as_word('SRAX 9'))

    @testing.clock

    @testing.ra.bytes.should eq (Word.new([0, 0, 0, 0, 0]).bytes)
    @testing.rx.bytes.should eq (Word.new([0, 0, 0, 0, 1]).bytes)
    @testing.rx.sign.should eq Sign::NEGATIVE
  end

  it 'Should correctly shift left circularly A and X one' do
    @testing.ra.load_value(Word.new([1, 2, 3, 4, 5]))
    @testing.rx.load_value(Word.new(Sign::NEGATIVE, [6, 7, 8, 9, 10]))
    @testing.change_memory_word(0, @instruction_parser.as_word('SLC 1'))

    @testing.clock

    @testing.ra.bytes.should eq (Word.new([2, 3, 4, 5, 6]).bytes)
    @testing.rx.bytes.should eq (Word.new([7, 8, 9, 10, 1]).bytes)
    @testing.rx.sign.should eq Sign::NEGATIVE
  end


  it 'Should correctly shift left circularly A and X forty-two' do
    @testing.ra.load_value(Word.new([1, 2, 3, 4, 5]))
    @testing.rx.load_value(Word.new(Sign::NEGATIVE, [6, 7, 8, 9, 10]))
    @testing.change_memory_word(0, @instruction_parser.as_word('SLC 42'))

    @testing.clock

    @testing.ra.bytes.should eq (Word.new([3, 4, 5, 6, 7]).bytes)
    @testing.rx.bytes.should eq (Word.new([8, 9, 10, 1, 2]).bytes)
    @testing.rx.sign.should eq Sign::NEGATIVE
  end
  it 'Should correctly shift right circularly A and X forty-two' do
    @testing.ra.load_value(Word.new([1, 2, 3, 4, 5]))
    @testing.rx.load_value(Word.new(Sign::NEGATIVE, [6, 7, 8, 9, 10]))
    @testing.change_memory_word(0, @instruction_parser.as_word('SRC 42'))

    @testing.clock

    @testing.ra.bytes.should eq (Word.new([9, 10, 1,2,3]).bytes)
    @testing.rx.bytes.should eq (Word.new([4,5,6,7,8]).bytes)
    @testing.rx.sign.should eq Sign::NEGATIVE
  end
  it 'should implement the complex case of TAOCP page 135' do
    @testing.ra.load_value(Word.new([1, 2, 3, 4, 5]))
    @testing.rx.load_value(Word.new(Sign::NEGATIVE, [6, 7, 8, 9, 10]))
    @testing.change_memory_word(0, @instruction_parser.as_word('SRAX 1'))
    @testing.change_memory_word(1, @instruction_parser.as_word('SLA 2'))
    @testing.change_memory_word(2, @instruction_parser.as_word('SRC 4'))
    @testing.change_memory_word(3, @instruction_parser.as_word('SRA 2'))
    @testing.change_memory_word(4, @instruction_parser.as_word('SLC 501'))

    5.times do
      @testing.clock
    end

    @testing.ra.bytes.should eq (Word.new([0,6,7,8,3]).bytes)
    @testing.ra.sign.should eq Sign::POSITIVE
    @testing.rx.bytes.should eq (Word.new([4,0,0,5,0]).bytes)
    @testing.rx.sign.should eq Sign::NEGATIVE

  end


end