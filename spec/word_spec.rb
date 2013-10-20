$:.unshift (File.dirname(__FILE__) + '/../src/')
$:.unshift (File.dirname(__FILE__) + '/../generated/')

require 'rspec'
require 'mix_core'
require 'word'

describe 'MIX word' do
  before(:each) do
    @to = Word.new(Sign::NEGATIVE, [1, 2, 3, 4, 5])
    @from = Word.new([6, 7, 8, 9, 0])
  end
  it 'should count five bytes' do
    Word.new.bytes.count.should eq 5
  end
  it 'should have a sign' do
    Word.new.sign.should eq 1
  end
  it 'should ignore bytes value greater than 63' do
    Word.new([65, 65, 65, 65, 65]).should eq Word.new([1, 1, 1, 1, 1])
  end

  it 'should be seen as a long' do
    Word.new([0, 0, 0, 0, 10]).long.should eq 10
    Word.new([0, 0, 0, 1, 0]).long.should eq 64
    Word.new([0, 0, 0, 1, 0]).long(0, 4).should eq 1
    Word.new([63, 63, 63, 63, 63]).long.should eq 1073741823
    Word.new(Sign::NEGATIVE, [63, 63, 63, 63, 63]).long.should eq -1073741823
    Word.new(Sign::NEGATIVE, [63, 63, 63, 63, 63]).long(0, 2).should eq -4095
  end

  it 'should be possible to assign from a long' do
    Word.new.store_long(65).bytes.should eq [0, 0, 0, 1, 1]
    Word.new.store_long(65).bytes.should eq [0, 0, 0, 1, 1]

  end

  it 'should be possible to increase the value of a word' do
    Word.new.store_long(65).increment_value(35).long.should eq 100
    Word.new.store_long(65).increment_value(-70).long.should eq -5
  end

  it 'should be possible to negate the word value' do
    Word.new.store_long(65).negate.long.should eq -65
  end

  it 'should implement correctly the store function as in The Art Of Computer Programming pag 130 - 1' do
    @to.store_value(@from)
    @to.should eq @from
  end

  it 'should implement correctly the store function as in The Art Of Computer Programming pag 130 - 2' do
    @to.store_value(@from, 1, 5)
    @to.should eq Word.new(Sign::NEGATIVE, @from.bytes)
  end

  it 'should implement correctly the store function as in The Art Of Computer Programming pag 130 - 3' do
    @to.store_value(@from, 5, 5)
    @to.should eq Word.new(Sign::NEGATIVE, [1, 2, 3, 4, 0])
  end
  it 'should implement correctly the store function as in The Art Of Computer Programming pag 130 - 4' do
    @to.store_value(@from, 2, 2)
    @to.should eq Word.new(Sign::NEGATIVE, [1, 0, 3, 4, 5])
  end
  it 'should implement correctly the store function as in The Art Of Computer Programming pag 130 - 5' do
    @to.store_value(@from, 2, 3)
    @to.should eq Word.new(Sign::NEGATIVE, [1, 9, 0, 4, 5])
  end
  it 'should implement correctly the store function as in The Art Of Computer Programming pag 130 - 6' do
    @to.store_value(@from, 0, 1)
    @to.should eq Word.new(Sign::POSITIVE, [0, 2, 3, 4, 5])
  end

end