$:.unshift (File.dirname(__FILE__) + '/../../src/')
$:.unshift (File.dirname(__FILE__) + '/../../generated/')
require 'rspec'
require 'mix_core'
require 'register'
require 'word'
require 'instructions'
require 'assembler'


describe 'Correctly implements various Operations' do
  before(:each) do
    @testing = MixCore.new
    @assembler = Assembler.new
    @address = 2500
    @register_word = Word.new([6, 7, 8, 9, 0])
    @testing.memory[@address].load_value(Word.new(Sign::NEGATIVE, [1, 2, 3, 4, 5]))

  end

  it 'should correctly halt' do
    @testing.change_memory_word(@testing.ip, @assembler.as_word('HLT'))

    @testing.clock

    @testing.halt.should eq true
    @testing.ip.should eq nil

  end

end