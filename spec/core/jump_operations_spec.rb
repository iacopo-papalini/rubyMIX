require File.dirname(__FILE__) +'/../../src/autoload.rb'
require 'rspec'

def assert_not_jumped_and_reset_ip
  @testing.rj.long.should eq 0
  @testing.ip.should eq @ip + 1
  @testing.force_instruction_pointer = @ip

end

def assert_jumped(tmp)
  @testing.rj.long.should eq (@ip + 1)
  @testing.ip.should eq tmp
end

describe 'Correctly implements jump Operations' do
  before(:each) do
    @testing = CPU.new
    @instruction_parser = InstructionParser.new
    @instruction_parser.expression_evaluator = ExpressionParser.new(nil)
    @address = 2500
    @shift = 3
    @ip = 100
    @testing.force_instruction_pointer @ip
    @testing.ri[0].store_long(@shift)
  end

  it 'should correctly perform a non conditional Jump' do
    @testing.change_memory_word(@ip, @instruction_parser.as_word('JMP %d,1' %@address))

    @testing.clock

    assert_jumped @address + @shift
  end

  it 'should correctly perform a jump saving J' do
    @testing.change_memory_word(@ip, @instruction_parser.as_word('JSJ %d' %@address))

    @testing.clock

    @testing.rj.long.should eq 0
    @testing.ip.should eq (@address)
  end

  it 'should correctly perform an overflow-conditioned Jump' do
    @testing.change_memory_word(@ip, @instruction_parser.as_word('JOV %d' %@address))

    @testing.clock

    assert_not_jumped_and_reset_ip

    @testing.alu.overflow = true

    @testing.clock

    # Overflow set
    assert_jumped @address
  end

  it 'should correctly perform a not-overflow-conditioned Jump' do
    @testing.change_memory_word(@ip, @instruction_parser.as_word('JNOV %d' %@address))
    @testing.alu.overflow = true

    @testing.clock

    assert_not_jumped_and_reset_ip
    @testing.alu.overflow = false

    @testing.clock

    # Overflow set
    assert_jumped @address
  end

  it 'should correctly perform a Jump if less' do
    @testing.change_memory_word(@ip, @instruction_parser.as_word('JL %d' %@address))
    @testing.clock

    assert_not_jumped_and_reset_ip

    @testing.alu.lt = true

    @testing.clock

    assert_jumped @address
  end

  it 'should correctly perform a Jump if equal' do
    @testing.change_memory_word(@ip, @instruction_parser.as_word('JE %d' %@address))
    @testing.alu.eq = true
    @testing.alu.gt = true

    @testing.clock

    assert_not_jumped_and_reset_ip

    @testing.alu.gt = false

    @testing.clock

    assert_jumped @address
  end

  it 'should correctly perform a Jump if greater' do
    @testing.change_memory_word(@ip, @instruction_parser.as_word('JG %d' %@address))
    @testing.alu.eq = true
    @testing.alu.gt = true

    @testing.clock

    assert_not_jumped_and_reset_ip

    @testing.alu.eq = false

    @testing.clock

    assert_jumped @address
  end

  it 'should correctly perform a Jump if greater or equals' do
    @testing.change_memory_word(@ip, @instruction_parser.as_word('JGE %d' %@address))
    @testing.alu.eq = false

    @testing.clock

    assert_not_jumped_and_reset_ip

    @testing.alu.eq = true

    @testing.clock

    assert_jumped @address
  end

  it 'should correctly perform a Jump if not equals' do
    @testing.change_memory_word(@ip, @instruction_parser.as_word('JNE %d' %@address))
    @testing.alu.eq = true
    @testing.alu.gt = false
    @testing.alu.lt = false

    @testing.clock

    assert_not_jumped_and_reset_ip

    @testing.alu.eq = true
    @testing.alu.lt = true
    @testing.clock

    assert_jumped @address
  end

  it 'should correctly perform a Jump if lesser or equals' do
    @testing.change_memory_word(@ip, @instruction_parser.as_word('JLE %d' %@address))
    @testing.alu.eq = false
    @testing.alu.gt = false
    @testing.alu.lt = false

    @testing.clock

    assert_not_jumped_and_reset_ip

    @testing.alu.eq = true
    @testing.alu.lt = true
    @testing.clock

    assert_jumped @address
  end
end