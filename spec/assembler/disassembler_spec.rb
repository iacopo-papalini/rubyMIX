require File.dirname(__FILE__) +'/../../src/autoload.rb'
require 'rspec'

def verify_instruction(instruction)
  word = @instruction_parser.as_word instruction
  @disassembler.disassemble(word).should eq instruction
end

describe 'Should convert instruction word to assembly' do
  before(:each) do
    @instruction_parser = InstructionParser.new()
    @instruction_parser.expression_evaluator = ExpressionParser.new(nil)
    @disassembler = Disassembler.new
  end

  it 'should convert correctly NOP' do
    verify_instruction('NOP')
  end
  it 'should convert correctly STA 1000' do
    verify_instruction('STA 1000')
  end

  it 'should convert correctly ADD 2999,2' do
    verify_instruction('ADD 2999,2')
  end
  it 'should convert correctly ADD 0,2' do
    verify_instruction('ADD 0,2')
  end
  it 'should convert correctly ADD 0,2' do
    verify_instruction('ADD 0,2')
  end
  it 'should convert correctly LDA 2000,2(1:3)' do
    verify_instruction('LDA 2000,2(1:3)')
  end

  it 'should convert correctly J1NZ 2000' do
    verify_instruction('J1NZ 2000')
  end
  it 'should convert correctly HLT' do
    verify_instruction('HLT')
  end

end