require File.dirname(__FILE__) +'/../../src/autoload.rb'
require 'rspec'


describe 'Correctly implements I/O Operations' do
  before(:each) do
    @testing = CPU.new
    @instruction_parser = InstructionParser.new
    @instruction_parser.expression_evaluator = ExpressionParser.new(nil)
  end


  it 'Should do nothing for IOC instruction' do
    @testing.change_memory_word(@testing.ip, @instruction_parser.as_word('IOC 0(18)'))
    @testing.clock
  end

  it 'Printer should be bound to identifier 18 and write correctly to buffer' do
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
end