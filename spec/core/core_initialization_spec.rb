$LOAD_PATH << File.dirname(__FILE__) +'/../../src'
$LOAD_PATH << File.dirname(__FILE__) +'/../../generated'
require 'rspec'
require 'core/cpu'
require 'assembler/instruction_parser'
require 'assembler/expression_parser'

describe 'Core initialization' do
  it 'should setup the cpu' do
    t = CPU.new (Logger.new(File.open('/dev/null', 'a')))
    all_registers_zero t
    t.ip.should eq 0
    t.mu.memory.size.should eq 4000
    t.mu.memory[0].should eq Word.new
    t.mu.memory[1].store_long(1)
    t.mu.memory[0].should_not eq t.mu.memory[1]
  end

  it 'loop doing nothing if started empty' do
    t = CPU.new (Logger.new(File.open('/dev/null', 'a')))
    1.upto 4000 do |cycle|
      t.clock
      t.ip.should eq cycle % 4000
      all_registers_zero t
    end
  end
end

def all_registers_zero(t)
  t.ra.should eq LongRegister.new('ra')
  t.rx.should eq LongRegister.new('rx')
  t.rj.should eq JumpRegister.new()
  t.ri.should eq Array.new(6, ShortRegister.new('ra'))
  t.alu.eq.should eq false
  t.alu.gt.should eq false
  t.alu.lt.should eq false
  t.alu.overflow.should eq false
end