require File.dirname(__FILE__) +'/../../src/autoload.rb'
require 'rspec'

describe 'Convert line to word' do
  before(:each) do
    @instruction_parser = InstructionParser.new
    @instruction_parser.expression_evaluator =  ExpressionParser.new(nil)
  end
  it 'should convert a NOP string to correct word' do
    @instruction_parser.as_word('NOP').bytes.should eq [0, 0, 0, 0, 0]
  end
  it 'should convert correctly a simple LDA instruction' do
    word = @instruction_parser.as_word('LDA 2000')
    word.bytes[4].should eq 8
    word.bytes[3].should eq 5
    word.bytes[2].should eq 0
    word.long(0,2).should eq 2000
  end

  it 'should convert correctly a LDA instruction' do
    word = @instruction_parser.as_word('LDA 2000,2(1:3)')
    word.bytes[4].should eq 8
    word.bytes[3].should eq 11
    word.bytes[2].should eq 2
    word.long(0,2).should eq 2000
  end
  it 'should convert correctly a ENT3 instruction' do
    word = @instruction_parser.as_word('ENT3      0,1')
    word.bytes[4].should eq 51
    word.bytes[3].should eq 2
    word.bytes[2].should eq 1
    word.long(0,2).should eq 0
  end
  it 'should convert correctly a ENT3 instruction' do
    word = @instruction_parser.as_word('ENT3      0,1')
    word.bytes[4].should eq 51
    word.bytes[3].should eq 2
    word.bytes[2].should eq 1
    word.long(0,2).should eq 0
  end

  it 'should convert correctly a ENTA instruction' do
    word = @instruction_parser.as_word('ENTA      65')
    word.bytes.should eq [1,1,0,2,48]

  end
  it 'should convert correctly a ENTA instruction with negative address' do
    word = @instruction_parser.as_word('ENTA      -65')
    word.bytes.should eq [1,1,0,2,48]
    word.sign.should eq Sign::NEGATIVE

  end

  it 'should parse correctly an EQU meta instruction' do
    instruction = @instruction_parser.as_instruction('EQU 1000')
    instruction.class.should eq EQUInstruction
    instruction.value.should eq 1000
    instruction.code.should eq 'EQU'
  end
end