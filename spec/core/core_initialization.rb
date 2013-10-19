$:.unshift (File.dirname(__FILE__) + '/../../src/')
require 'rspec'
require 'mix_core'
require 'register'
require 'word'
require 'assembler'


describe 'Core initialization' do
  it 'should setup the cpu' do
    t = MixCore.new
    all_registers_zero t
    t.ip.should eq 0
    t.memory.size.should eq 4000
    t.memory[0].should eq Word.new
    t.memory[1].store_long(1)
    t.memory[0].should_not eq t.memory[1]

    # TODO add I/O
  end

  it 'loop doing nothing if started empty' do
    t = MixCore.new
    1.upto 4000 do |cycle|
      t.clock
      t.ip.should eq cycle % 4000
      all_registers_zero t
    end
  end



end

def all_registers_zero(t)
  t.ra.should eq Register::Big.new
  t.rx.should eq Register::Big.new
  t.rj.should eq Register::Jump.new
  t.ri.should eq Array.new(6, Register::Small.new)
  t.eq.should eq false
  t.gt.should eq false
  t.lt.should eq false
  t.overflow.should eq false
end