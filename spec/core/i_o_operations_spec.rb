$LOAD_PATH << File.dirname(__FILE__) +'/../../src'
$LOAD_PATH << File.dirname(__FILE__) +'/../../generated'
require 'rspec'
require 'core/cpu'
require 'assembler/instruction_parser'
require 'assembler/expression_parser'
require 'devices'

describe 'Correctly implements I/O Operations' do
  before(:each) do
    logger = Logger.new(File.open('/dev/null', 'a'))
    #logger = Logger.new(STDOUT)
    @testing = CPU.new (logger)
    @instruction_parser = InstructionParser.new
    @instruction_parser.expression_evaluator = ExpressionParser.new(nil)
  end


  it 'Should do nothing for IOC instruction' do
    @testing.change_memory_word(@testing.ip, @instruction_parser.as_word('IOC 0(18)'))
    @testing.clock
  end

  it 'should bound the printer to identifier 18 and write correctly to buffer' do
    printer = 18
    @testing.change_memory_word(@testing.ip, @instruction_parser.as_word('OUT 10(%d)' % printer))
    (10..100).each do |address|
      @testing.change_memory_word(address, Word.new().store_string('ABCDE'))
    end
    test_string =''
    @testing.bind_io_device(printer, test_string)

    @testing.clock

    test_string.length.should eq 121
    test_string.should eq 'ABCDE' * 24 + "\n"
  end

  it 'should bound the paper tape to identifier 20 and read correctly from buffer' do
    paper_tape = 20
    string = StringIO.new('ABCDEFGHILMNOP' * 5)
    @testing.change_memory_word(@testing.ip, @instruction_parser.as_word('IN 10(%d)' % paper_tape))
    @testing.bind_io_device(paper_tape, string)

    @testing.clock
    @testing.mu.memory[9].long.should eq 0
    @testing.mu.memory[10].string.should eq 'ABCDE'
    @testing.mu.memory[11].string.should eq 'FGHIL'
    @testing.mu.memory[12].string.should eq 'MNOPA'
    @testing.mu.memory[13].string.should eq 'BCDEF'
    @testing.mu.memory[14].string.should eq 'GHILM'
    @testing.mu.memory[15].string.should eq 'NOPAB'
    @testing.mu.memory[16].string.should eq 'CDEFG'
    @testing.mu.memory[17].string.should eq 'HILMN'
    @testing.mu.memory[18].string.should eq 'OPABC'
    @testing.mu.memory[19].string.should eq 'DEFGH'
    @testing.mu.memory[20].string.should eq 'ILMNO'
    @testing.mu.memory[21].string.should eq 'PABCD'
    @testing.mu.memory[22].string.should eq 'EFGHI'
    @testing.mu.memory[23].string.should eq 'LMNOP'
    @testing.mu.memory[24].long.should eq 0
  end

  it 'should treat new lines as blank spaces and lowercase as uppercase' do
    paper_tape = 20
    string = StringIO.new("ab\nCD")
    @testing.change_memory_word(@testing.ip, @instruction_parser.as_word('IN 10(%d)' % paper_tape))
    @testing.bind_io_device(paper_tape, string)

    @testing.clock
    @testing.mu.memory[10].string.should eq 'AB CD'

  end
end