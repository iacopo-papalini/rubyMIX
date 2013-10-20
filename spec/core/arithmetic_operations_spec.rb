$:.unshift (File.dirname(__FILE__) + '/../../src/')
$:.unshift (File.dirname(__FILE__) + '/../../generated/')
require 'rspec'
require 'mix_core'
require 'register'
require 'word'
require 'assembler'

describe 'Correctly implements arithmetic Operations' do
  before(:each) do
    @testing = MixCore.new
    @assembler = Assembler.new
    @address = 2500
    @fix_num = -65 # [0,0,0,1,1]
    @register_value = 80
    @testing.change_memory_word(@address, Word.new.store_long(@fix_num))
    @testing.ra.store_long(@register_value)


  end

  it 'should add the value of the memory cell to rA' do
    @testing.change_memory_word(@testing.ip, @assembler.as_word('ADD %d' % @address))

    @testing.clock

    @testing.ra.long.should eq @register_value+@fix_num
  end
  it 'should add the partial value of the memory cell to rA' do
    @testing.change_memory_word(@testing.ip, @assembler.as_word('ADD %d(5:5)' % @address))

    @testing.clock

    @testing.ra.long.should eq @register_value+1
  end

  it 'should handle the overflow' do
    @testing.change_memory_word(@address, Word.new.store_long(Limits::MAX_INT - 1 ))
    @testing.change_memory_word(@testing.ip, @assembler.as_word('ADD %d' % @address))

    @testing.clock

    @testing.ra.long.should eq @register_value - 1
    @testing.overflow.should eq true
  end

  it 'should handle the underflow' do
    @testing.ra.store_long(-@register_value)
    @testing.change_memory_word(@address, Word.new.store_long(-Limits::MAX_INT + 1 ))
    @testing.change_memory_word(@testing.ip, @assembler.as_word('ADD %d' % @address))
    @testing.overflow.should eq false
    @testing.clock

    @testing.ra.long.should eq (- @register_value + 1)
    @testing.overflow.should eq true
  end

  it 'should subtract the value of the memory cell to rA' do
    @testing.change_memory_word(@testing.ip, @assembler.as_word('SUB %d' % @address))

    @testing.clock

    @testing.ra.long.should eq @register_value - @fix_num
  end
end