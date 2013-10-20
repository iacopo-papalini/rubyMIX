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

describe 'Correctly implements jump Operations that check register values' do
  before(:each) do
    @testing = MixCore.new
    @assembler = Assembler.new
    @address = 2500
    @shift = 3
    @ip = 100;
    @testing.ip = @ip;
    @testing.ri[0].store_long(@shift)
  end

  it 'should correctly perform a jump if A negative conditional Jump' do
    @testing.change_memory_word(@ip, @assembler.as_word('JAN %d,1' %@address))
    @testing.clock
    assert_not_jumped_and_reset_ip

    @testing.ra.store_long(-1)
    @testing.clock

    assert_jumped @address + @shift
  end

  it 'should correctly perform a jump if I1 zero conditional Jump' do
    @testing.change_memory_word(@ip, @assembler.as_word('J1Z %d' %@address))
    @testing.ri[0].store_long(1)
    @testing.clock
    assert_not_jumped_and_reset_ip

    @testing.ri[0].store_long(0)
    @testing.clock

    assert_jumped @address
  end

  it 'should correctly perform a jump if I2 positive conditional Jump' do
    @testing.change_memory_word(@ip, @assembler.as_word('J2P %d' %@address))
    @testing.ri[1].store_long(-1)
    @testing.clock
    assert_not_jumped_and_reset_ip

    @testing.ri[1].store_long(0)
    @testing.clock
    assert_not_jumped_and_reset_ip

    @testing.ri[1].store_long(1)
    @testing.clock
    assert_jumped @address
  end

end