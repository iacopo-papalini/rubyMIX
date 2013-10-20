$:.unshift (File.dirname(__FILE__) + '/../src/')
$:.unshift (File.dirname(__FILE__) + '/../generated/')
require 'rspec'
require 'word'
require 'assembler'
require 'instructions'

describe 'Convert line to word' do
  before(:each) do
    @assembler = Assembler.new
  end
  it 'should convert a NOP string to correct word' do
    @assembler.as_word('NOP').bytes.should eq [0, 0, 0, 0, 0]
  end
  it 'should convert correctly a simple LDA instruction' do
    word = @assembler.as_word('LDA 2000')
    word.bytes[4].should eq 8
    word.bytes[3].should eq 5
    word.bytes[2].should eq 0
    word.long(0,2).should eq 2000
  end

  it 'should convert correctly a LDA instruction' do
    word = @assembler.as_word('LDA 2000,2(1:3)')
    word.bytes[4].should eq 8
    word.bytes[3].should eq 11
    word.bytes[2].should eq 2
    word.long(0,2).should eq 2000
  end
  it 'should convert correctly a ENT3 instruction' do
    word = @assembler.as_word('ENT3      0,1')
    word.bytes[4].should eq 51
    word.bytes[3].should eq 2
    word.bytes[2].should eq 1
    word.long(0,2).should eq 0
  end
  it 'should convert correctly a ENT3 instruction' do
    word = @assembler.as_word('ENT3      0,1')
    word.bytes[4].should eq 51
    word.bytes[3].should eq 2
    word.bytes[2].should eq 1
    word.long(0,2).should eq 0
  end

  it 'should convert correctly a ENTA instruction' do
    word = @assembler.as_word('ENTA      65')
    word.bytes.should eq [1,1,0,2,48]

  end

end