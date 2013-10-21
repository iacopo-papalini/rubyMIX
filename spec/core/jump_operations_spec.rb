$:.unshift (File.dirname(__FILE__) + '/../../src/')
$:.unshift (File.dirname(__FILE__) + '/../../generated/')
require 'rspec'
require 'mix_core'
require 'register'
require 'word'
require 'assembler'
require 'instructions'

def assert_not_jumped_and_reset_ip
  @testing.rj.long.should eq 0
  @testing.ip.should eq @ip + 1
  @testing.ip = @ip

end

def assert_jumped(tmp)
  @testing.rj.long.should eq (@ip + 1)
  @testing.ip.should eq tmp
end

describe 'Correctly implements jump Operations' do
  before(:each) do
    @testing = MixCore.new
    @assembler = Assembler.new
    @address = 2500
    @shift = 3
    @ip = 100
    @testing.ip = @ip
    @testing.ri[0].store_long(@shift)
  end

  it 'should correctly perform a non conditional Jump' do
    @testing.change_memory_word(@ip, @assembler.as_word('JMP %d,1' %@address))

    @testing.clock

    assert_jumped @address + @shift
  end

  it 'should correctly perform a jump saving J' do
    @testing.change_memory_word(@ip, @assembler.as_word('JSJ %d' %@address))

    @testing.clock

    @testing.rj.long.should eq 0
    @testing.ip.should eq (@address)
  end

  it 'should correctly perform an overflow-conditioned Jump' do
    @testing.change_memory_word(@ip, @assembler.as_word('JOV %d' %@address))

    @testing.clock

    assert_not_jumped_and_reset_ip

    @testing.overflow = true

    @testing.clock

    # Overflow set
    assert_jumped @address
  end

  it 'should correctly perform a not-overflow-conditioned Jump' do
    @testing.change_memory_word(@ip, @assembler.as_word('JNOV %d' %@address))
    @testing.overflow = true

    @testing.clock

    assert_not_jumped_and_reset_ip
    @testing.overflow = false

    @testing.clock

    # Overflow set
    assert_jumped @address
  end

  it 'should correctly perform a Jump if less' do
    @testing.change_memory_word(@ip, @assembler.as_word('JL %d' %@address))
    @testing.clock

    assert_not_jumped_and_reset_ip

    @testing.lt = true

    @testing.clock

    assert_jumped @address
  end

  it 'should correctly perform a Jump if equal' do
    @testing.change_memory_word(@ip, @assembler.as_word('JE %d' %@address))
    @testing.eq = true
    @testing.gt = true

    @testing.clock

    assert_not_jumped_and_reset_ip

    @testing.gt = false

    @testing.clock

    assert_jumped @address
  end

  it 'should correctly perform a Jump if greater' do
    @testing.change_memory_word(@ip, @assembler.as_word('JG %d' %@address))
    @testing.eq = true
    @testing.gt = true

    @testing.clock

    assert_not_jumped_and_reset_ip

    @testing.eq = false

    @testing.clock

    assert_jumped @address
  end

  it 'should correctly perform a Jump if greater or equals' do
    @testing.change_memory_word(@ip, @assembler.as_word('JGE %d' %@address))
    @testing.eq = false

    @testing.clock

    assert_not_jumped_and_reset_ip

    @testing.eq = true

    @testing.clock

    assert_jumped @address
  end

  it 'should correctly perform a Jump if not equals' do
    @testing.change_memory_word(@ip, @assembler.as_word('JNE %d' %@address))
    @testing.eq = true
    @testing.gt = false
    @testing.lt = false

    @testing.clock

    assert_not_jumped_and_reset_ip

    @testing.eq = true
    @testing.lt = true
    @testing.clock

    assert_jumped @address
  end

  it 'should correctly perform a Jump if lesser or equals' do
    @testing.change_memory_word(@ip, @assembler.as_word('JLE %d' %@address))
    @testing.eq = false
    @testing.gt = false
    @testing.lt = false

    @testing.clock

    assert_not_jumped_and_reset_ip

    @testing.eq = true
    @testing.lt = true
    @testing.clock

    assert_jumped @address
  end
end